import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property variant projectId: "";

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        PushUpMenu {
            MenuItem {
                text: qsTr("Scroll to top")
                onClicked: view.scrollToTop()
            }
        }

        width: parent.width;
        height: parent.height

        ListModel { id: projectActivityList }

        SilicaListView {
            id: view

            header: PageHeader {
                title: qsTr("Project activities")
            }

            ViewPlaceholder {
                text: qsTr("Nothing here")
                hintText: qsTr("Check your settings")
            }

            width: parent.width
            height: parent.height
            model: projectActivityList
            delegate: ListItem {
                width: parent.width
                height: Theme.itemSizeMedium

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("StartTracking.qml"), {projectId: projectId, activityId: id})
                }

                Label { text: name }
            }
            Component.onCompleted: {
                /*getContextsFromTracks(); */
                getProjectActivities(projectId, projectActivityList);
            }
        }
    }
}
