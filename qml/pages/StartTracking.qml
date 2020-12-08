import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: page

    property variant projectId: "";
    property variant activityId: "";

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    ListModel { id: projectActivityList }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        id: addform
        anchors.fill: parent

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            DialogHeader {
                acceptText: qsTr("Start tracking")
            }

            TextField {
                id: description
                focus: true
                width: parent.width
                placeholderText: qsTr("Description")
                label: qsTr("Description")

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: note.focus = true
            }

            ComboBox {
                id: project
                width: parent.width
                label: qsTr("Project")
                value: qsTr("Select")

                menu: ContextMenu {
                    Repeater {
                        model: projectList
                        MenuItem {
                            text: name
                            onClicked: {
                                project.value = name
                                page.projectId = projectId
                            }
                        }
                    }
                    onActivated: {
                        getProjectActivities(page.projectId, projectActivityList);
                        activity.enabled = true
                        activity.menu.popup()
                    }
                }

                Component.onCompleted: {
                    getProjects();
                    for(var i = 0; i < projectList.count; ++i) {
                        if (projectList.get(i).projectId == projectId) {
                            project.currentIndex = i;
                            activity.enabled = true
                        }
                    }
                }
            }

            ComboBox {
                id: activity
                width: parent.width
                label: qsTr("Activity")
                enabled: false
                value: qsTr("Select")

                menu: ContextMenu {
                    Repeater {
                        model: projectActivityList
                        MenuItem {
                            text: name
                            onClicked: {
                                activity.value = name
                                page.activityId = activityId
                            }
                        }
                    }
                }
            }

            ValueButton {
                id: beginDate
                label: qsTr("Begin date")
                value: qsTr("Select")
                width: parent.width
                Component.onCompleted: {
                    value = new Date().toLocaleDateString(Qt.locale("en-GB"), "yyyy-MM-dd")
                }
                onClicked: {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {date: new Date()})

                    dialog.accepted.connect(function() {
                        value = dialog.date.toLocaleDateString(Qt.locale("en-GB"), "yyyy-MM-dd")
                    })
                }
            }

            ValueButton {
                id: beginTime
                label: qsTr("Begin time")
                width: parent.width
                Component.onCompleted: {
                    value = new Date().toLocaleTimeString(Qt.locale("en-GB"), "hh:mm")
                }
                onClicked: {
                    var parts = value.split(':')
                    var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {hour: parts[0], minute: parts[1]})

                    dialog.accepted.connect(function() {
                        value = dialog.timeText
                    })
                }
            }
        }
    }

    onAccepted: {
        startTracking(projectId, activityId, description)
    }

    function startTracking(projectId, activityId, description) {
        var requestData = {};
        console.log(description.text);
        requestData['begin'] = beginDate.value + 'T' + beginTime.value + ':00'
        requestData['project'] = projectId
        requestData['activity'] = activityId
        requestData['description'] = description.text
//        requestData['end'] =
//        requestData['duration'] =
        console.log(JSON.stringify(requestData));

        request("timesheets", "post", JSON.stringify(requestData), function(doc) {
            console.log(doc.status);
            console.log(doc.responseText);
            var m = messageNotification.createObject(null);
            if (doc.status === 201) {
                m.body = qsTr("Activity %1 started tracking for %2.").arg(description.text).arg(context.value);
                m.summary = qsTr("Activity tracking started")
            }
            else {
                m.body = qsTr("Starting activity %1 tracking failed.").arg(description.text);
                m.summary = qsTr("Activity tracking failed")
            }
            m.previewSummary = m.summary
            m.previewBody = m.body
            m.publish()
        });
    }
}
