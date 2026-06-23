import Quickshell
import Quickshell.Io
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import qs.CustomTheme

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 20

    property bool isOpen: false
    property int soundCount: 1

    // LOUDNESS SLIDER
    RowLayout {
        Layout.fillWidth: true
        spacing: 15

        Text {
            text: "" // Speaker icon
            color: Theme.primary
            font.family: "monospace"
            font.pixelSize: 18
            Layout.alignment: Qt.AlignVCenter
        }

        Slider {
            id: volumeSlider
            Layout.fillWidth: true
            from: 0
            to: 100
            value: 50 // Default

            Process {
                command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"]
                running: root.isOpen
                stdout: StdioCollector {
                    onStreamFinished: {
                        let val = parseInt(this.text.trim());
                        if (!isNaN(val))
                            volumeSlider.value = val;
                    }
                }
            }

            onMoved: {
                Quickshell.execDetached(["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.round(value) + "%"]);
            }

            background: Rectangle {
                x: volumeSlider.leftPadding
                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 6
                width: volumeSlider.availableWidth
                height: implicitHeight
                radius: 3
                color: Theme.background
                border.color: Theme.primary
                border.width: 1

                Rectangle {
                    width: volumeSlider.visualPosition * parent.width
                    height: parent.height
                    color: Theme.primary
                    radius: 3
                }
            }

            handle: Rectangle {
                x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                implicitWidth: 16
                implicitHeight: 16
                radius: 8
                color: volumeSlider.pressed ? Theme.background : Theme.primary
                border.color: Theme.primary
                border.width: 1
            }
        }
    }

    // SOUND SLIDERS (one per sink)
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 20

        Text {
            text: "Sound"
            color: Theme.primary
            font.family: "monospace"
            font.pixelSize: 18
            Layout.alignment: Qt.AlignVCenter
        }

        Repeater {
            model: root.soundCount

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 15

                Text {
                    text: " " + (index + 1)
                    color: Theme.primary
                    font.family: "monospace"
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignVCenter
                }

                Slider {
                    id: soundSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: 50 // Default

                    Process {
                        command: ["bash", "-c", "pactl get-sink-volume " + (index) + " | grep -o '[0-9]*%' | head -1 | sed 's/%//'" ]
                        running: root.isOpen
                        stdout: StdioCollector {
                            onStreamFinished: {
                                let v = parseInt(this.text.trim());
                                if (!isNaN(v))
                                    soundSlider.value = v;
                            }
                        }
                    }

                    onMoved: {
                        Quickshell.execDetached(["bash", "-c", "pactl set-sink-volume " + (index) + " " + Math.round(value) + "%"]);
                    }

                    background: Rectangle {
                        x: soundSlider.leftPadding
                        y: soundSlider.topPadding + soundSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 6
                        width: soundSlider.availableWidth
                        height: implicitHeight
                        radius: 3
                        color: Theme.background
                        border.color: Theme.primary
                        border.width: 1

                        Rectangle {
                            width: soundSlider.visualPosition * parent.width
                            height: parent.height
                            color: Theme.primary
                            radius: 3
                        }
                    }

                    handle: Rectangle {
                        x: soundSlider.leftPadding + soundSlider.visualPosition * (soundSlider.availableWidth - width)
                        y: soundSlider.topPadding + soundSlider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: soundSlider.pressed ? Theme.background : Theme.primary
                        border.color: Theme.primary
                        border.width: 1
                    }
                }
            }
        }
    }
}

