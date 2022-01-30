import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: lookupPage
    objectName: "lookupPage"
    title: qsTr("Lookup")
    background: null

    ScrollView {
        id: lookupPageScrollView
        anchors.fill: parent
        contentWidth: parent.width
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

            Repeater {
                id: lookupRepeater

                ColumnLayout {
                    RowLayout {
                        spacing: dp(8)
                        Text {
                            text: modelData.engine
                            font.bold: true
                            font.italic: true
                            font.pixelSize: sp(20)
                            font.family: aliceInWonderlandFont.name
                            color: Qt.rgba(0, 0, 0, 0.6)
                        }
                        Rectangle {
                            implicitHeight: dp(2)
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                            color: Qt.rgba(0, 0, 0, 0.38)
                        }
                    }
                    Loader {
                        Layout.fillWidth: true
                        sourceComponent: qd.dict(modelData.engine).delegate ? qd.dict(modelData.engine).delegate : dictDelegate
                        
                        onLoaded: item.modelData = modelData
                    }
                }
            }
            // placeholder to lift text off the bottom
            Item {
                implicitHeight: dp(8)
            }
        }
    }

    Component {
        id: dictDelegate

        ColumnLayout {
            property var modelData

            RowLayout {
                spacing: dp(8)
                Text {
                    text: modelData.text
                    font.bold: true
                    font.pixelSize: sp(14)
                }
                Repeater {
                    model: modelData.phonetic
                    Loader {
                        source: "components/Phonetic.ui.qml"
                        onLoaded: item.modelData = modelData
                    }
                }
            }
            Repeater {
                model: modelData.definitions
                ColumnLayout {
                    RowLayout {
                        spacing: dp(8)
                        Text {
                            text: typeof modelData.group !== "undefined" ? modelData.group : null
                            visible: text ? true : false
                            font.bold: true
                            font.pixelSize: sp(12)
                            color: Qt.rgba(0, 0, 0, 0.6)
                        }
                        Loader {
                            source: "components/Phonetic.ui.qml"
                            active: typeof modelData.phonetic !== "undefined"
                            onLoaded: item.modelData = modelData.phonetic
                        }
                    }
                    ColumnLayout {
                        Layout.leftMargin: dp(8)

                        Repeater {
                            model: modelData.list

                            RowLayout {
                                Text {
                                    text: index + 1
                                    font.pixelSize: sp(12)
                                    color: Qt.rgba(0, 0, 0, 0.6)
                                    Layout.alignment: Qt.AlignTop
                                }
                                ColumnLayout {
                                    Layout.minimumWidth: 0
                                    TextEdit {
                                        text: modelData.definition
                                        font.pixelSize: sp(12)
                                        Layout.fillWidth: boundingRect.width > parent.width
                                        wrapMode: Text.Wrap
                                        readOnly: true
                                        selectByMouse: true

                                        property rect boundingRect: Qt.rect(0, 0, 0, 0)

                                        Component.onCompleted: {
                                            boundingRect = qd.textBoundingRect(font, text)
                                        }
                                    }
                                    Repeater {
                                        model: modelData.examples

                                        RowLayout {
                                            Layout.minimumWidth: 0
                                            Text {
                                                id: bulletText
                                                text: "\u2022"
                                                font.pixelSize: sp(12)
                                                color: Qt.rgba(0, 0, 0, 0.6)
                                                Layout.alignment: Qt.AlignTop
                                            }
                                            TextEdit {
                                                text: modelData
                                                font.pixelSize: sp(12)
                                                Layout.fillWidth: bulletText.width + parent.spacing + boundingRect.width > parent.width
                                                wrapMode: Text.Wrap
                                                readOnly: true
                                                selectByMouse: true

                                                property rect boundingRect: Qt.rect(0, 0, 0, 0)

                                                Component.onCompleted: {
                                                    boundingRect = qd.textBoundingRect(font, text)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function updateResults(results) {
        if (!results.length)
            lookupPageScrollView.ScrollBar.vertical.position = 0
        lookupRepeater.model = results
    }
    function scrollUp(step = 0.1) {
        let relativeStep = 100.0 / (lookupPageScrollView.contentHeight / dp(1)) * step
        lookupPageScrollView.ScrollBar.vertical.position = Math.min(lookupPageScrollView.ScrollBar.vertical.position + relativeStep, 1.0 - lookupPageScrollView.ScrollBar.vertical.size)
    }
    function scrollDown(step = 0.1) {
        let relativeStep = 100.0 / (lookupPageScrollView.contentHeight / dp(1)) * step
        lookupPageScrollView.ScrollBar.vertical.position = Math.max(lookupPageScrollView.ScrollBar.vertical.position - relativeStep, 0.0)
    }
}
