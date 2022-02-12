import QtQuick 2.15
import com.quickdict.components 1.0
import QtQuick.Controls 2.15
import QtMultimedia 5.15

Dict {
    id: googleTts
    name: "Google TTS"
    property string tl: "en"
    property bool autoPlay: false
    property url url: "http://translate.google.com/translate_tts?sl=auto&tl=(tl)&client=tw-ob&q="
    delegate: Component {
        Button {
            property var modelData
            text: qsTr("Play")
            font.pixelSize: sp(14)

            Audio {
                id: googleTtsAudio
            }

            onClicked: {
                googleTtsAudio.play()
            }
            onModelDataChanged: {
                googleTtsAudio.source = modelData.url
                if (modelData.autoPlay)
                    googleTtsAudio.play()
            }
        }
    }

    onQuery: {
        let audioUrl = String(url).replace("(tl)", tl) + text
        let result = {"engine": name, "text": text, "url": audioUrl, "autoPlay": autoPlay, "type": "lookup"}
        queryResult(result)
    }
}
