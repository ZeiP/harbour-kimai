import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    ListModel { id: recentTimesheetsList }

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
                    getRecentTimesheets();
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
                title: qsTr("Recent timesheets")
            }

            ViewPlaceholder {
/*                enabled: contextList.count == 0 */
                text: qsTr("Nothing here")
                hintText: qsTr("Check your settings")
            }

            width: parent.width
            height: parent.height
            model: recentTimesheetsList
            delegate: ListItem {
                id: listItem
                width: ListView.view.width
                contentHeight: Theme.itemSizeSmall
                menu: contextMenu
                ListView.onRemove: animateRemoval(listItem)

                function remove() {
                    remorseAction(qsTr("Deleting the timesheet"), function() {
                        var item = view.model.get(index);
                        deleteTimesheet(item.timesheetId);
                        view.model.remove(index);
                    })
                }

                Label {
                    id: label
                    text: qsTr("%1: %2 h – %3 € @ %4").arg(description).arg((duration / 60 / 60).toFixed(2).toString()).arg(rate.toFixed(2)).arg(beginDate)
                }
                Label {
                    anchors.top: label.bottom
                    anchors.right: parent.right
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: activityName + "@" + projectName
                }

                Component {
                    id: contextMenu
                    ContextMenu {
                        MenuItem {
                            text: "Delete"
                            onClicked: remove()
                            enabled: true
                        }
                    }
                }
            }
            Component.onCompleted: {
                getRecentTimesheets();
            }
        }
    }

    function getRecentTimesheets() {
        request("timesheets?active=0&full=true", "get", "", function(doc) {
            var e = JSON.parse(doc.responseText);
            console.log(doc.responseText);
            recentTimesheetsList.clear();
            for(var i = 0; i < e.length; i++) {
                var tl = e[i];
                var item = {}
                item.timesheetId = tl.id;
                item.projectName = tl.project.name;
                item.projectId = tl.project.id;
                item.activityName = tl.activity.name;
                item.activityId = tl.activity.id;
                item.description = tl.description;
                item.begin = tl.begin;
                var date = new Date(tl.begin);
                item.beginDate = date.getDate() + "." + date.getMonth() + "."
                item.end = tl.end;
                item.duration = tl.duration;
                item.rate = tl.rate;
                recentTimesheetsList.append(item);
            }
        });
    }

    function deleteTimesheet(timesheetId) {
        console.log("Deleteing" + timesheetId);
        request("timesheets/" + timesheetId, "delete", "", function(doc) {
            console.log(doc.status);
            console.log(doc.responseText);
            var m = messageNotification.createObject(null);
            if (doc.status === 204) {
                m.body = qsTr("Activity %1 deleted.").arg(timesheetId);
                m.summary = qsTr("Activity deleted")
            }
            else {
                m.body = qsTr("Deleting activity %1 failed.").arg(timesheetId);
                m.summary = qsTr("Activity delete failed")
            }
            m.previewSummary = m.summary
            m.previewBody = m.body
            m.publish()
        });
    }
}
