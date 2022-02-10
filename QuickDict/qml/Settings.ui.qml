import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: settingsPage
    objectName: "settingsPage"
    background: null
    title: qsTr("Settings")

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: layout.implicitHeight + dp(16) // with margins
        clip: true

        ColumnLayout {
            id: layout
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: dp(8)
            }
            spacing: dp(16)

            ColumnLayout {
                RowLayout {
                    spacing: dp(8)
                    Text {
                        text: qsTr("Language")
                        font.bold: true
                        font.italic: true
                        font.pixelSize: sp(20)
                        color: Qt.rgba(0, 0, 0, 0.6)
                    }
                    Rectangle {
                        Layout.preferredHeight: 2
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        color: Qt.rgba(0, 0, 0, 0.38)
                    }
                }
                RowLayout {
                    Text {
                        text: qsTr("Source Language:")
                        font.pixelSize: sp(14)
                    }
                    ComboBox {
                        model: qd.availableLocales()
                        font.pixelSize: sp(14)
                        Layout.fillWidth: true

                        onActivated: qd.configCenter.setValue("/lang/sl", currentText)

                        Component.onCompleted: {
                            let lang = qd.configCenter.value("/lang/sl", "en_US")
                            currentIndex = model.indexOf(lang)
                        }
                    }
                }
                RowLayout {
                    Text {
                        text: qsTr("Target Language:")
                        font.pixelSize: sp(14)
                    }
                    ComboBox {
                        model: qd.availableLocales()
                        font.pixelSize: sp(14)
                        Layout.fillWidth: true

                        onActivated: qd.configCenter.setValue("/lang/tl", currentText)

                        Component.onCompleted: {
                            let lang = qd.configCenter.value("/lang/tl", "en_US")
                            currentIndex = model.indexOf(lang)
                        }
                    }
                }
            }

            ColumnLayout {
                RowLayout {
                    spacing: dp(8)
                    Text {
                        text: qsTr("Interface")
                        font.bold: true
                        font.italic: true
                        font.pixelSize: sp(20)
                        color: Qt.rgba(0, 0, 0, 0.6)
                    }
                    Rectangle {
                        Layout.preferredHeight: 2
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        color: Qt.rgba(0, 0, 0, 0.38)
                    }
                }
                RowLayout {
                    Text {
                        text: qsTr("Font Family:")
                        font.pixelSize: sp(14)
                    }
                    ComboBox {
                        model: Qt.fontFamilies()
                        font.pixelSize: sp(14)
                        Layout.fillWidth: true

                        onActivated: {
                            qd.fontFamily = currentText
                            qd.configCenter.setValue("/interface/fontFamily", currentText)
                        }

                        Component.onCompleted: currentIndex = model.indexOf(qd.fontFamily)
                    }
                }
                RowLayout {
                    Text {
                        text: qsTr("Scale Factor:")
                        font.pixelSize: sp(14)
                    }
                    Slider {
                        id: scaleFactorSlider
                        from: 1.0
                        to: 3.0
                        Layout.fillWidth: true

                        Component.onCompleted: value = qd.spScale
                        onMoved: {
                            qd.spScale = value
                            qd.configCenter.setValue("/interface/scaleFactor", qd.spScale)
                        }
                    }
                    Text {
                        text: `${Math.round(scaleFactorSlider.value * 100)}%`
                        font.pixelSize: sp(14)
                    }
                }
            }

            ColumnLayout {
                RowLayout {
                    spacing: dp(8)
                    Text {
                        text: qsTr("Monitors")
                        font.bold: true
                        font.italic: true
                        font.pixelSize: sp(20)
                        color: Qt.rgba(0, 0, 0, 0.6)
                    }
                    Rectangle {
                        Layout.preferredHeight: 2
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        color: Qt.rgba(0, 0, 0, 0.38)
                    }
                }

                Repeater {
                    model: qd.monitors.sort((first, second) => first.name.localeCompare(second.name))
                    delegate: CheckBox {
                        checked: modelData.enabled
                        text: modelData.name
                        font.pixelSize: sp(14)
                        ToolTip.visible: hovered
                        ToolTip.text: modelData.description

                        onToggled: {
                            modelData.toggle()
                        }
                        Component.onCompleted: {
                            if (text === "TextFieldMonitor")
                                enabled = false
                            // NOTE: The tooltip won't show up when the control is disabled in Qt 5.15.2. This bug is fixed in Qt 6.1. see https://bugreports.qt.io/browse/QTBUG-30801.
                        }
                    }
                }
            }

            ColumnLayout {
                RowLayout {
                    spacing: dp(8)
                    Text {
                        text: qsTr("Dictionaries")
                        font.bold: true
                        font.italic: true
                        font.pixelSize: sp(20)
                        color: Qt.rgba(0, 0, 0, 0.6)
                    }
                    Rectangle {
                        Layout.preferredHeight: 2
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        color: Qt.rgba(0, 0, 0, 0.38)
                    }
                }

                Repeater {
                    model: qd.dicts.sort((first, second) => first.name.localeCompare(second.name))
                    delegate: CheckBox {
                        checked: modelData.enabled
                        text: modelData.name
                        font.pixelSize: sp(14)
                        ToolTip.visible: hovered && modelData.description
                        ToolTip.text: modelData.description

                        onToggled: modelData.toggle()
                    }
                }
            }
        }
    }
}
