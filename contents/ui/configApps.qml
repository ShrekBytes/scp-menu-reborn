import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasma5support as Plasma5Support

KCM.SimpleKCM {
    property string cfg_appList
    property ListModel appsModel: ListModel {}
    property ListModel userAppsModel: ListModel {
        onDataChanged: saveApps()
        onCountChanged: saveApps()
        onRowsMoved: saveApps()
    }

    function saveApps() {
        const newAppConfig = new Map()
        for (let i = 0; i < userAppsModel.count; i++) {
            const app = userAppsModel.get(i)
            newAppConfig.set(app.menuId, { iconName: app.iconName })
        }
        cfg_appList = JSON.stringify(Array.from(newAppConfig.entries()));
    }

    Plasma5Support.DataSource {
        id: appSource
        engine: "apps"
        connectedSources: sources

        function getUserApps() {
            try {
                var apps = new Map(JSON.parse(cfg_appList))
                return Array.from(apps.entries()).map(function(entry) {
                    return Object.assign({}, data[entry[0]], entry[1])
                })
            } catch (e) {
                return []
            }
        }

        function getAllApps() {
            var keys = []
            try {
                keys = data.keys ? data.keys() : Object.keys(data)
            } catch (e) {
                keys = Object.keys(data)
            }
            return keys
                .map(function(i) { return data[i] })
                .filter(function(i) { return i && i.display && i.isApp })
                .sort(function(a, b) { return a.name.localeCompare(b.name) })
        }

        Component.onCompleted: {
            appsModel.append(getAllApps())
            userAppsModel.append(getUserApps())
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        Kirigami.Heading {
            text: i18n("App Launchers")
            level: 4
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        Label {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing
            text: i18n("Choose application and hit plus:")
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: Kirigami.Units.largeSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing

            ComboBox {
                id: appSelector
                Layout.fillWidth: true
                editable: true
                textRole: "name"
                model: appsModel
                onAccepted: {
                    if (find(currentText) !== -1) {
                        userAppsModel.append(model.get(currentIndex))
                        currentIndex = -1
                        editText = ""
                    }
                }
            }
            Button {
                icon.name: "list-add"
                onClicked: appSelector.accepted()
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        ListView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            id: userAppList
            clip: true
            spacing: 0
            model: userAppsModel
            delegate: appListItem
            ScrollBar.vertical: ScrollBar {
                active: true
            }
        }

        Component {
            id: appListItem
            ItemDelegate {
                width: ListView.view.width / 1.05
                contentItem: RowLayout {
                    ConfigIcon {
                        value: model.iconName
                        onValueChanged: model.iconName = value
                    }
                    Label {
                        text: model.name
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    ToolButton {
                        icon.name: 'arrow-up'
                        enabled: index > 0
                        onClicked: userAppList.model.move(index, index - 1, 1)
                    }
                    ToolButton {
                        icon.name: 'arrow-down'
                        enabled: index > -1 && index < userAppList.model.count - 1
                        onClicked: userAppList.model.move(index, index + 1, 1)
                    }
                    ToolButton {
                        icon.name: 'delete'
                        onClicked: userAppList.model.remove(index)
                    }
                }
            }
        }
    }
}
