import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.sessions as Sessions
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    property string iconSett: Plasmoid.configuration.icon
    property bool twoColumnLayout: Plasmoid.configuration.twoColumnLayout
    property bool showButtonBorders: Plasmoid.configuration.showButtonBorders
    property string sessionButtonsConfig: Plasmoid.configuration.sessionButtons

    // Model of enabled session buttons (rebuilt when config changes)
    property ListModel sessionModel: ListModel {}
    readonly property bool hasAnyButton: sessionModel.count > 0

    // Button label/icon lookup tables — built once rather than reconstructed on every call
    readonly property var buttonLabels: ({
        "lock":      i18n("Lock Screen"),
        "logout":    i18n("Log Out"),
        "restart":   i18n("Restart"),
        "sleep":     i18n("Sleep"),
        "shutdown":  i18n("Shut Down"),
        "hibernate": i18n("Hibernate")
    })
    readonly property var buttonIcons: ({
        "lock":      "system-lock-screen",
        "logout":    "system-log-out",
        "restart":   "system-reboot",
        "sleep":     "system-suspend",
        "shutdown":  "system-shutdown",
        "hibernate": "system-suspend-hibernate"
    })

    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 12

    // Ensure the popup height always matches current content
    onExpandedChanged: {
        if (expanded && Plasmoid.fullRepresentationItem) {
            Plasmoid.fullRepresentationItem.Layout.preferredHeight = column.implicitHeight
        }
    }

    onSessionButtonsConfigChanged: rebuildSessionModel()
    Component.onCompleted: rebuildSessionModel()

    function rebuildSessionModel() {
        sessionModel.clear()
        try {
            var buttons = JSON.parse(sessionButtonsConfig)
            for (var i = 0; i < buttons.length; i++) {
                if (buttons[i].enabled) {
                    // Hide hibernate if system doesn't support it
                    if (buttons[i].id === "hibernate" && !sm.canHibernate) continue
                    sessionModel.append({ buttonId: buttons[i].id })
                }
            }
        } catch(e) {}
    }

    function executeSessionAction(bid) {
        switch (bid) {
            case "lock": sm.lock(); break
            case "logout": sm.requestLogout(); break
            case "restart": sm.requestReboot(); break
            case "sleep": sm.suspend(); break
            case "shutdown": sm.requestShutdown(); break
            case "hibernate": sm.hibernate(); break
        }
        root.expanded = false
    }

    // Data source for loading app information from the apps engine
    Plasma5Support.DataSource {
        id: apps
        engine: "apps"

        property string appListConfig: Plasmoid.configuration.appList
        property ListModel model: ListModel {}
        property var userApps: new Map()

        function reload() {
            model.clear()
            try {
                userApps = new Map(JSON.parse(appListConfig))
            } catch (e) {
                userApps = new Map()
            }
            Array.from(userApps.keys()).forEach(function(key) {
                connectSource(key)
            })
        }

        onNewData: function(sourceName, data) {
            var extra = (userApps && userApps.get) ? userApps.get(sourceName) : null
            model.append(Object.assign({}, data, extra || {}))
            disconnectSource(sourceName)
        }

        onAppListConfigChanged: reload()
        Component.onCompleted: reload()
    }

    // Executable data source to launch applications
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
        }
    }

    Sessions.SessionManagement {
        id: sm
    }

    function launchApp(desktopFile) {
        executable.connectSource("kioclient exec 'file://" + desktopFile + "'")
    }

    compactRepresentation: Kirigami.Icon {
        source: root.iconSett || "configure"
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
            cursorShape: Qt.PointingHandCursor
        }
    }

    fullRepresentation: Item {
        id: fullRoot

        implicitHeight: column.implicitHeight
        implicitWidth: column.implicitWidth

        Layout.preferredWidth: Kirigami.Units.gridUnit * 14
        Layout.preferredHeight: implicitHeight
        Layout.minimumWidth: Layout.preferredWidth
        Layout.minimumHeight: Layout.preferredHeight
        Layout.maximumWidth: Layout.preferredWidth
        Layout.maximumHeight: Screen.height

        ColumnLayout {
            id: column

            anchors.fill: parent
            anchors.leftMargin: Kirigami.Units.smallSpacing
            anchors.rightMargin: Kirigami.Units.smallSpacing
            anchors.topMargin: Kirigami.Units.smallSpacing * 0.5
            anchors.bottomMargin: Kirigami.Units.smallSpacing * 0.5
            spacing: 0

            // App shortcuts section
            ColumnLayout {
                id: appColumn
                spacing: 0

                Repeater {
                    model: apps.model

                    ActionListDelegate {
                        Layout.fillWidth: true
                        text: model.name
                        icon.name: model.iconName
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.launchApp(model.entryPath)
                        }
                    }
                }
            }

            // Separator between apps and power buttons
            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing * 1
                Layout.bottomMargin: Kirigami.Units.smallSpacing * 2
                visible: apps.model.count > 0 && root.hasAnyButton
            }

            // Power / session buttons — dynamic model-driven layout
            GridLayout {
                id: powerGrid
                columns: root.twoColumnLayout ? 2 : 1
                Layout.fillWidth: true
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                rowSpacing: Kirigami.Units.mediumSpacing
                columnSpacing: Kirigami.Units.mediumSpacing
                visible: root.hasAnyButton

                Repeater {
                    model: root.sessionModel

                    PlasmaComponents.ItemDelegate {
                        readonly property bool isUnpaired: root.twoColumnLayout
                            && index === root.sessionModel.count - 1
                            && root.sessionModel.count % 2 !== 0

                        Layout.fillWidth: true
                        Layout.columnSpan: isUnpaired ? 2 : 1
                        topPadding: Kirigami.Units.mediumSpacing
                        bottomPadding: Kirigami.Units.mediumSpacing
                        leftPadding: Kirigami.Units.mediumSpacing
                        rightPadding: Kirigami.Units.mediumSpacing

                        contentItem: RowLayout {
                            spacing: Kirigami.Units.smallSpacing
                            Item { Layout.fillWidth: isUnpaired }
                            Kirigami.Icon {
                                source: root.buttonIcons[model.buttonId] || ""
                                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                            }
                            PlasmaComponents.Label {
                                text: root.buttonLabels[model.buttonId] || model.buttonId
                                Layout.fillWidth: !isUnpaired
                            }
                            Item { Layout.fillWidth: isUnpaired }
                        }

                        // Optional border on top of default background
                        Rectangle {
                            anchors.fill: parent
                            radius: Kirigami.Units.smallSpacing
                            color: "transparent"
                            border.width: root.showButtonBorders ? 1 : 0
                            border.color: root.showButtonBorders
                                ? Qt.rgba(Kirigami.Theme.textColor.r,
                                          Kirigami.Theme.textColor.g,
                                          Kirigami.Theme.textColor.b, 0.2)
                                : "transparent"
                            z: 1
                            enabled: false  // decorative only — do not consume mouse events
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.executeSessionAction(model.buttonId)
                        }
                    }
                }
            }
        }
    }
}
