import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "common"

import Nemo.Notifications 1.0

ApplicationWindow
{
    id: mainWindow

    initialPage: Component { Tracker { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    Settings {
        id: settings
    }

    Component {
        id: messageNotification
        Notification {}
    }

/*    ListModel { id: contextList } */

    ListModel { id: projectList }

    function request(params, method, data, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = (function(mxhr) {
            return function() { if(mxhr.readyState === XMLHttpRequest.DONE) { callback(mxhr); } }
        })(xhr);

        // Check that the URL ends in slash.
        var url = settings.base_url
        if (url.substr(url.length - 1) !== "/") {
            url = url + "/";
        }
        url = url + params;

        xhr.open(method, url, true);
        xhr.responseType = 'json';
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Accept", "application/json");
        xhr.setRequestHeader("X-AUTH-USER", settings.username);
        xhr.setRequestHeader("X-AUTH-TOKEN", settings.token);
        if(method === "post" || method === "put") {
            xhr.send(data);
        }
        else {
            xhr.send('');
        }
    }
/*
    function getContextsFromTracks() {
        request("contexts.xml", "get", "", function(doc) {
            contextList.clear();
            for(var i = 0; i < e.childNodes.length; i++) {
                if(e.childNodes[i].nodeName === "context") {
                    var tl = e.childNodes[i];
                    var item = {}
                    for(var j = 0; j < tl.childNodes.length; j++) {
                        if(tl.childNodes[j].nodeName === "name") {
                            item.name = tl.childNodes[j].childNodes[0].nodeValue;
                        }
                        if(tl.childNodes[j].nodeName === "id") {
                            item.contextId = tl.childNodes[j].childNodes[0].nodeValue;
                        }
                        if(tl.childNodes[j].nodeName === "state") {
                            item.state = tl.childNodes[j].childNodes[0].nodeValue;
                        }
                    }
                    if (item.state == 'active') {
                        contextList.append(item);
                    }
                }
            }
        });
    }

    function getContextIdFromName(contextName) {
        for (var i = 0; i < contextList.count; i++) {
            var value = contextList.get(i);
            if (contextName === value.name) {
                return value.contextId;
            }
        }
    }
*/
    function getProjects() {
        request("projects?visible=1", "get", "", function(doc) {
            var e = JSON.parse(doc.responseText);
            projectList.clear();
            for(var i = 0; i < e.length; i++) {
                var tl = e[i];
                console.log(tl);
                var item = {}
                item.name = tl.name;
                item.projectId = tl.id;
                projectList.append(item);
            }
        });
    }

    function getProjectActivities(projectId, model) {
        request("activities?project=" + projectId, "get", "", function(doc) {
            var e = JSON.parse(doc.responseText);
            model.clear();
            for(var i = 0; i < e.length; i++) {
                var tl = e[i];
                console.log(tl);
                var item = {}
                item.name = tl.name;
                item.id = tl.projectId;
                model.append(item);
            }
        });
    }
/*
    function getProjectIdFromName(projectName) {
        for (var i = 0; i < projectList.count; i++) {
            var value = projectList.get(i);
            if (projectName === value.name) {
                return value.projectId;
            }
        }
    }
*/
    Component.onCompleted: {
        var m = messageNotification.createObject(null);
    }
}
