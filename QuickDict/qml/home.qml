import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1
import com.quickdict.components 1.0
import "axios.min.js" as Axios

ApplicationWindow {
    id: window
    objectName: "window"
    title: stackView.depth > 1 ? stackView.currentItem.title + qsTr(" - QuickDict") : qsTr("QuickDict")
    width: dp(320)
    height: dp(380)
    minimumWidth: dp(250)
    minimumHeight: dp(200)
    color: "#f6f3ed"

    header: ToolBar {
        font.pixelSize: sp(24)
        contentHeight: toolButton.implicitHeight
        spacing: dp(8)

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }
        TextField {
            id: textField
            placeholderText: qsTr("look up...")
            bottomPadding: dp(8)
            visible: stackView.depth <= 1
            anchors {
                left: toolButton.right
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: dp(8)
            }

            Monitor {
                id: textFieldMonitor
                name: qsTr("TextFieldMonitor")
                enabled: true
                description: qsTr("TextFieldMonitor monitors text in TextField.")

                Component.onCompleted: {
                    qd.registerMonitor(textFieldMonitor)
                }
            }

            onAccepted: {
                textFieldMonitor.query(text)
            }
        }
        Label {
            text: stackView.currentItem.title
            visible: stackView.depth > 1
            anchors.centerIn: parent
        }
    }

    Drawer {
        id: drawer
        width: Math.min(dp(256), 0.6 * window.width)
        height: window.height
        font.pixelSize: sp(20)

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Settings")
                width: parent.width
                onClicked: {
                    stackView.push("Settings.ui.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("About")
                width: parent.width
                onClicked: {
                    stackView.push("About.ui.qml")
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "Main.ui.qml"
        anchors.fill: parent
    }

    SystemTrayIcon {
        id: systemTrayIcon
        visible: true
        icon.source: "qrc:/images/QuickDict-32x32.png"

        menu: Menu {
            visible: false
            MenuItem {
                text: qsTr("Show")
                onTriggered: {
                    focusOnTextField()
                    showOnTop()
                }
            }
            MenuItem {
                text: qsTr("Quit")
                onTriggered: Qt.quit()
            }
        }

        onActivated: {
            // if reason is DoubleClick/Trigger/MiddleClick
            if (reason >= 2) {
                focusOnTextField()
                showOnTop()
            }
        }
    }

    Loader {
        id: userInitLoader
        source: StandardPaths.locate(StandardPaths.GenericConfigLocation, "QuickDict/qml/init.qml")
        active: false
        asynchronous: true
    }

    FontLoader {
        id: aliceInWonderlandFont
        source: "qrc:/fonts/Alice_in_Wonderland_3.ttf"
    }

    Timer {
        // use timer to reduce the number of save operations
        id: saveGeometryTimer
        interval: 500

        onTriggered: saveGeometry()
    }

    Connections {
        target: qd
        function onQuery(text) {
            textField.text = text
            showOnTop()
        }
        function onQueryResult(result) {
            stackView.forceActiveFocus()
        }
    }

    onXChanged: startSaveGeometryTimer()
    onYChanged: startSaveGeometryTimer()
    onWidthChanged: startSaveGeometryTimer()
    onHeightChanged: startSaveGeometryTimer()

    Component.onCompleted: {
        let geometry = qd.configCenter.value("/geometry")
        if (geometry) {
            window.x = geometry.x
            window.y = geometry.y
            window.width = geometry.width
            window.height = geometry.height
        }
        userInitLoader.active = true

        textField.forceActiveFocus()
    }

    function showOnTop() {
        if (!window.visible)
            window.show()
        window.raise()
        window.requestActivate()
    }

    function focusOnTextField() {
        while (stackView.depth > 1)
            stackView.pop()
        if (drawer.activeFocus)
            drawer.close()
        textField.forceActiveFocus()
        textField.selectAll()
    }

    function saveGeometry() {
        qd.configCenter.setValue("/geometry", Qt.rect(window.x, window.y, window.width, window.height))
    }

    function startSaveGeometryTimer() {
        saveGeometryTimer.restart()
    }
}
