import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    ListModel { id: activeTimesheetsList }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Statistics")
                onClicked: pageStack.push(Qt.resolvedUrl("Statistics.qml"))
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    getActiveTimesheets();
                }
            }
            MenuItem {
                text: qsTr("Track time")
                onClicked: pageStack.push(Qt.resolvedUrl("StartTracking.qml"))
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Scroll to top")
                onClicked: view.scrollToTop()
            }
        }

        width: parent.width;
        height: parent.height

        SilicaListView {
            id: view

            header: PageHeader {
                title: qsTr("Active timesheets")
            }

            ViewPlaceholder {
/*                enabled: contextList.count == 0 */
                text: qsTr("Nothing here")
                hintText: qsTr("Check your settings")
            }

            width: parent.width
            height: parent.height
            model: activeTimesheetsList
            delegate: ListItem {
                id: listItem
                width: ListView.view.width
                contentHeight: Theme.itemSizeSmall
                menu: contextMenu
                ListView.onRemove: animateRemoval(listItem)

                function stop() {
                    remorseAction(qsTr("Stopping the timesheet"), function() {
                        var item = view.model.get(index);
                        view.model.remove(index)
                        stopTimesheet(item.timesheetId, item.description);
                    })
                }

                Label {
                    id: label
                    text: description
                }
                Label {
                    anchors.top: label.bottom
                    anchors.right: parent.right
                    font.pixelSize: Theme.fontSizeSmall
                    text: activityName + "@" + projectName
                }

                Component {
                    id: contextMenu
                    ContextMenu {
                        MenuItem {
                            text: "Stop"
                            onClicked: stop()
                            enabled: false
                        }
                    }
                }
            }
            Component.onCompleted: {
                getActiveTimesheets();
            }
        }
    }

    function getActiveTimesheets() {
        request("timesheets/active", "get", "", function(doc) {
            var e = JSON.parse(doc.responseText);
            console.log(doc.responseText);
            activeTimesheetsList.clear();
            for(var i = 0; i < e.length; i++) {
                var tl = e[i];
                var item = {}
                item.timesheetId = tl.id;
                item.projectName = tl.project.name;
                item.projectId = tl.project.id;
                item.activityName = tl.activity.name;
                item.activityId = tl.activity.id;
                item.description = tl.description;
                console.log(item);
                activeTimesheetsList.append(item);
            }
        });
    }
    function stopTimesheet(timesheetId) {
        request("timesheets/" + timesheetId + "/stop", "patch", "", function(doc) {
            console.log(doc.status);
            console.log(doc.responseText);
            var m = messageNotification.createObject(null);
            if (doc.status === 200) {
                m.body = qsTr("Activity %1 stopped tracking for %2.").arg(description.text).arg(context.value);
                m.summary = qsTr("Activity tracking stopped")
            }
            else {
                m.body = qsTr("Stopping activity %1 tracking failed.").arg(description.text);
                m.summary = qsTr("Activity tracking failed")
            }
            m.previewSummary = m.summary
            m.previewBody = m.body
            m.publish()
        });
    }
}
