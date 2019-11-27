/*
 * Copyright 2019 Marco Martin <mart@kde.org>
 * Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Controls
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

Window {
    id: window
    color: Qt.rgba(0, 0, 0, 0.8)

    width: screen.availableGeometry.width
    height: screen.availableGeometry.height
    Timer {
        interval: 10000
        running: Mycroft.MycroftController.status != Mycroft.MycroftController.Open
        onTriggered: {
            print("Trying to connect to Mycroft");
            Mycroft.MycroftController.start();
        }
    }
    onVisibleChanged: {
        skillView.open = visible;
    }

    Mycroft.StatusIndicator {
        z: 2
        anchors {
            right: parent.right
            top: parent.top
            margins: Kirigami.Units.largeSpacing
            topMargin: Kirigami.Units.largeSpacing + plasmoid.availableScreenRect.y
        }
    }

    Rectangle {
        id: skillStatusArea
        height: Kirigami.Units.iconSizes.huge
        anchors.left: parent.left
        anchors.right: parent.right
        color: Kirigami.Theme.backgroundColor
        
        RowLayout {
            anchors.fill: parent
            
            Kirigami.Heading {
                id: inputQuery
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.fillHeight: true
                Layout.fillWidth: true
                font.capitalization: Font.Capitalize
                level: 3
                Connections {
                target: Mycroft.MycroftController
                onIntentRecevied: { 
                    if(type == "recognizer_loop:utterance") {
                        inputQuery.text = data.utterances[0]
                        }
                    }
                }
            }
            
            Rectangle {
                id: closeButton
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                Layout.fillHeight: true
                color: focus ? Kirigami.Theme.highlightColor :"transparent"
                
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: Kirigami.Units.iconSizes.large
                    source: "tab-close"
                }
                
                Keys.onReturnPressed: {
                    window.visible = false;
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        window.visible = false;
                    }
                }
            }
        }
    }
    
    Mycroft.SkillView {
        id: skillView
        anchors {
            top: skillStatusArea.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        open: false
        Keys.onEscapePressed: window.visible = false;
        onOpenChanged: {
            if (open) {
                window.showMaximized();
            } else {
                window.visible = false;
            }
        }
    }
        //FIXME: find a better way for timeouts
        //onActiveSkillClosed: open = false;
/*
        topPadding: plasmoid.availableScreenRect.y
        bottomPadding: root.height - plasmoid.availableScreenRect.y - plasmoid.availableScreenRect.height
        leftPadding: plasmoid.availableScreenRect.x
        rightPadding: root.width - plasmoid.availableScreenRect.x - plasmoid.availableScreenRect.width
        */
}
