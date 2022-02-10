#include "clipboardmonitor.h"
#include "configcenter.h"
#include "dictservice.h"
#ifdef ENABLE_QHOTKEY
#include "hotkey.h"
#endif
#include "mdxdict.h"
#include "mobidict.h"
#ifdef ENABLE_TESSERACT
#include "mouseovermonitor.h"
#include "ocrengine.h"
#endif
#include "quickdict.h"

#if ENABLE_KWIN_BLUR
#include <KWindowEffects>
#endif
#include <QApplication>
#include <QCommandLineParser>
#include <QDir>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QTimer>
#include <QWindow>

#if defined(_MSC_VER) || defined(__MINGW64__)
#include <Windows.h>
#endif

static QFile logFile;
static QtMessageHandler defaultMessageHandler;
static bool debugFlag;

void messageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    static QMutex mutex;
    QMutexLocker lock(&mutex);

    logFile.write(qFormatLogMessage(type, context, message).toUtf8().append('\n'));
    logFile.flush();

    if (debugFlag)
        defaultMessageHandler(type, context, message); // output to the terminal
}

int main(int argc, char *argv[])
{
#if defined(_MSC_VER) || defined(__MINGW64__)
    if (AttachConsole(ATTACH_PARENT_PROCESS)) {
        freopen("CONOUT$", "w", stdout);
        freopen("CONOUT$", "w", stderr);
    }
#endif

#ifdef ENABLE_TESSERACT
    qRegisterMetaType<OcrResult>("OcrResult");
#endif
    qmlRegisterType<MonitorService>("com.quickdict.components", 1, 0, "Monitor");
    qmlRegisterType<DictService>("com.quickdict.components", 1, 0, "Dict");
    qmlRegisterType<MobiDict>("com.quickdict.components", 1, 0, "MobiDict");
    qmlRegisterType<MdxDict>("com.quickdict.components", 1, 0, "MdxDict");
#ifdef ENABLE_QHOTKEY
    qmlRegisterType<Hotkey>("com.quickdict.components", 1, 0, "Hotkey");
#endif

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    // fix "WebEngineContext used before QtWebEngine::initialize() or OpenGL context creation failed."
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    // QQmlApplicationEngine requires QAppliction
    QApplication app(argc, argv);
    app.setOrganizationName("QuickDict");
    app.setOrganizationDomain("https://github.com/QuickDict/QuickDict");
    app.setApplicationName("QuickDict");
    app.setApplicationVersion("0.3.0");
    app.setWindowIcon(QIcon(":/images/QuickDict-32x32.png"));

    app.setQuitOnLastWindowClosed(false);

    QCommandLineParser parser;
    parser.setApplicationDescription(QObject::tr("QuickDict is a cross-platform dictionary/translation application."));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption({{"d", "debug"}, QObject::tr("Print log messages.")});
    parser.process(app);

    debugFlag = parser.isSet("debug");

    QString messagePattern =
#ifdef QT_DEBUG
        "[%{time yyyy-MM-dd h:mm:ss.zzz t} "
        "%{if-debug}D%{endif}%{if-info}I%{endif}%{if-warning}W%{endif}%{if-critical}C%{endif}%{if-fatal}"
        "F%{endif}] %{category} %{threadid} %{file}:%{line} - %{message}";
#else
        "[%{time yyyy-MM-dd h:mm:ss.zzz t} "
        "%{if-debug}D%{endif}%{if-info}I%{endif}%{if-warning}W%{endif}%{if-critical}C%{endif}%{if-fatal}F%{endif}] "
        "%{category} %{threadid} - %{message}";
#endif
    qSetMessagePattern(messagePattern);
    QLoggingCategory::setFilterRules("qd.*=true");
    if (!debugFlag)
        QLoggingCategory::setFilterRules("qd.*.debug=false");

    logFile.setFileName(QDir(QuickDict::logDirPath()).filePath("log"));
    if (!logFile.open(QIODevice::Append | QIODevice::Text))
        qCWarning(qd) << "Cannot open file:" << logFile.fileName();
    else
        defaultMessageHandler = qInstallMessageHandler(messageHandler);

    QuickDict::createInstance();
    QuickDict *quickDict = QuickDict::instance();

    ConfigCenter configCenter(QDir(QuickDict::configDirPath()).filePath("settings.ini"));
    quickDict->setConfigCenter(&configCenter);

#ifdef ENABLE_TESSERACT
    OcrEngine ocrEngine;
    quickDict->setOcrEngine(&ocrEngine);
#endif

    ClipboardMonitor clipboardMonitor(quickDict);
    quickDict->registerMonitor(&clipboardMonitor);

#ifdef ENABLE_TESSERACT
    MouseOverMonitor mouseOverMonitor(quickDict);
    quickDict->registerMonitor(&mouseOverMonitor);
#endif

    // we set font family before loading qmls to make font family change global,
    // i.e. also changes the font family of home.qml
    QVariant fontFamily = configCenter.value("/interface/fontFamily");
    if (fontFamily.isValid())
        quickDict->setFontFamily(fontFamily.toString());

    QQmlApplicationEngine engine(quickDict);
    const QUrl url(QStringLiteral("qrc:/home.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    // register `qd` in js engine
    engine.rootContext()->setContextProperty("qd", quickDict);
    // register `setTimeout` in js engine
    engine.rootContext()->setContextObject(quickDict);
    engine.load(url);

    // we set scale factor after loading qmls to make scale factor change local,
    // i.e. does not change the scale factor of home.qml
    QVariant scaleFactor = configCenter.value("/interface/scaleFactor");
    if (scaleFactor.isValid())
        quickDict->setSpScale(scaleFactor.toDouble());

    QTimer::singleShot(200, quickDict, [quickDict]() { quickDict->loadConfig(); });

    QWindow *window = qobject_cast<QWindow *>(engine.rootObjects().at(0));
#if ENABLE_KWIN_BLUR
    // window->setProperty("color", "transparent");
    KWindowEffects::enableBlurBehind(window);
#endif
    window->show();

    int ret = app.exec();

#ifdef ENABLE_TESSERACT
    ocrEngine.stop();
#endif
    logFile.close();

    return ret;
}
