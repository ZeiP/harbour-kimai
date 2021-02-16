import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    ListModel { id: statsList }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    getUserStats();
                }
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
                title: qsTr("Time stats")
            }

            width: parent.width
            height: parent.height
            model: statsList
            delegate: DetailItem {
                width: parent.width
                height: Theme.itemSizeMedium
                label: statName
                value: statValue
            }
            Component.onCompleted: {
                getUserStats();
            }
        }
    }

    function getUserStats() {
        request("reports/user", "get", "", function(doc) {
            var e = JSON.parse(doc.responseText);
            statsList.clear();

            var item = {
                "statName": "",
                "statValue": ""
            };
            item.statName = qsTr("Duration this month")
            item.statValue = qsTr("%1 hours").arg((e.durationThisMonth / 60 / 60).toFixed(2).toString())
            statsList.append(item);

            item.statName = qsTr("Total duration")
            item.statValue = qsTr("%1 hours").arg((e.durationTotal / 60 / 60).toFixed(2).toString())
            statsList.append(item);

            item.statName = qsTr("Amount this month")
            item.statValue = e.amountThisMonth.toFixed(2) + " €"
            statsList.append(item);

            item.statName = qsTr("Total amount")
            item.statValue = e.amountTotal.toFixed(2) + " €"
            statsList.append(item);

            item.statName = qsTr("First entry")
            item.statValue = e.firstEntry
            statsList.append(item);

            item.statName = qsTr("Total records")
            item.statValue = qsTr("%1 pcs").arg(e.recordsTotal.toString())
            statsList.append(item);
        });
    }
}
