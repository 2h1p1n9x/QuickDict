import QtQuick 2.15
import com.quickdict.components 1.0
import QtQuick.Layouts 1.15
import "UrbanDict" as UrbanDict
import "DictdDict" as DictdDict
import "GoogleTranslate" as GoogleTranslate
import "MoeDict" as MoeDict
import "MockDict" as MockDict
import "DeepLTranslate" as DeepLTranslate
import "OxfordDictionaries" as OxfordDictionaries
import "ExampleDict" as ExampleDict

Item {
    property var mainPage: {"currentIndex": 0} // this default value is to prevent warning of undefined property
    property var lookupPage

    MdxDict {
        id: exampleMdxDict
        name: "Example Mdx Dict"
        source: "/home/user/Dictionaries/Example_Mdx_Dict.mdx"
        delegate: dictDelegate
    }
    MobiDict {
        id: exampleMobiDict
        name: "Example Mobi Dict"
        source: "/home/user/Dictionaries/Example_Mobi_Dict.mobi"
        delegate: dictDelegate
    }
    UrbanDict.UrbanDict {
        id: urbanDict
    }
    DictdDict.DictdDict {
        id: dictdDict
    }
    GoogleTranslate.GoogleTranslate {
        id: googleTranslate
    }
    MoeDict.MoeDict {
        id: moeDict
    }
    MockDict.MockDict {
        id: mockDict
    }
    DeepLTranslate.DeepLTranslate {
        authKey: "your-auth-key"
    }
    OxfordDictionaries.OxfordDictionaries {
        id: oxfordDictionaries
        appId: "your-appId"
        appKey: "your-appKey"
        strictMatch: true
    }
    ExampleDict.ExampleDict {
        id: exampleDict
    }

    Shortcut {
        // hide QuickDict window
        sequence: "Esc"
        context: Qt.ApplicationShortcut
        onActivated: window.hide()
    }
    Shortcut {
        // quit QuickDict
        sequence: StandardKey.Quit
        context: Qt.ApplicationShortcut
        onActivated: Qt.quit()
    }
    Shortcut {
        // focus on TextField
        sequence: "Ctrl+L"
        context: Qt.ApplicationShortcut
        onActivated: window.focusOnTextField()
    }
    Shortcut {
        // swipe left on mainPage
        sequence: "H"
        enabled: mainPage.currentIndex == 1

        onActivated: mainPage.currentIndex = 0
    }
    Shortcut {
        // swipe right on mainPage
        sequence: "L"
        enabled: mainPage.currentIndex == 0

        onActivated: mainPage.currentIndex = 1
    }
    Shortcut {
        // scroll up lookup page
        sequence: "J"
        enabled: mainPage.currentIndex == 0

        onActivated: {
            if (mainPage.currentIndex == 0)
                lookupPage.scrollUp()
        }
    }
    Shortcut {
        // scroll down lookup page
        sequence: "K"
        enabled: mainPage.currentIndex == 0

        onActivated: {
            if (mainPage.currentIndex == 0)
                lookupPage.scrollDown()
        }
    }
    Hotkey {
        // activate QuickDict
        sequence: "Alt+Q"
        onActivated: {
            if (!window.visible)
                window.focusOnTextField()
            window.showOnTop()
        }
    }
    Hotkey {
        // toogle ClipboardMonitor
        sequence: "Alt+C"
        onActivated: {
            let m = qd.monitor("ClipboardMonitor")
            if (m)
                m.toggle()
        }
    }
    Hotkey {
        // toogle MouseOverMonitor
        sequence: "Alt+O"
        onActivated: {
            let m = qd.monitor("MouseOverMonitor")
            if (m)
                m.toggle()
        }
    }

    Component {
        id: dictDelegate
        TextEdit {
            id: text
            property var modelData
            text: modelData.result
            font.pixelSize: sp(14)
            textFormat: TextEdit.RichText
            wrapMode: Text.Wrap
            readOnly: true
            selectByMouse: true
            Layout.fillWidth: true
        }
    }

    Component.onCompleted: {
        // wait all components are loaded
        setTimeout(() => {
            mainPage = qd.findChild("mainPage", window)
            lookupPage = qd.findChild("lookupPage", window)
        }, 500)
    }
}
