import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.private.sessions as Sessions

KCM.SimpleKCM {

    Sessions.SessionManagement {
        id: sm
    }

    property alias cfg_icon: icon.text
    property alias cfg_twoColumnLayout: twoColumnToggle.checked
    property alias cfg_showButtonBorders: borderToggle.checked
    property string cfg_sessionButtons

    // Button metadata
    readonly property var buttonMeta: ({
        "lock":      { label: i18n("Lock Screen"), icon: "system-lock-screen" },
        "logout":    { label: i18n("Log Out"),      icon: "system-log-out" },
        "restart":   { label: i18n("Restart"),      icon: "system-reboot" },
        "sleep":     { label: i18n("Sleep"),         icon: "system-suspend" },
        "shutdown":  { label: i18n("Shut Down"),     icon: "system-shutdown" },
        "hibernate": { label: i18n("Hibernate"),     icon: "system-suspend-hibernate" }
    })

    property ListModel buttonsModel: ListModel {}

    Component.onCompleted: loadButtons()

    function loadButtons() {
        buttonsModel.clear()
        try {
            var buttons = JSON.parse(cfg_sessionButtons)
            for (var i = 0; i < buttons.length; i++) {
                buttonsModel.append(buttons[i])
            }
        } catch(e) {}
    }

    function saveButtons() {
        var arr = []
        for (var i = 0; i < buttonsModel.count; i++) {
            var item = buttonsModel.get(i)
            arr.push({ id: item.id, enabled: item.enabled })
        }
        cfg_sessionButtons = JSON.stringify(arr)
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        Kirigami.FormLayout {
            Layout.fillWidth: true

            RowLayout {
                Kirigami.FormData.label: i18n("Widget Icon:")
                spacing: Kirigami.Units.smallSpacing

                ConfigIcon {
                    value: icon.text
                    onValueChanged: icon.text = value
                }

                TextField {
                    id: icon
                    implicitWidth: 200
                    placeholderText: i18n("Icon name…")
                }
            }

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: i18n("Layout")
            }

            CheckBox {
                id: twoColumnToggle
                Kirigami.FormData.label: i18n("Two-column button layout")
            }

            CheckBox {
                id: borderToggle
                Kirigami.FormData.label: i18n("Show button borders")
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        Kirigami.Heading {
            text: i18n("Session Buttons")
            level: 4
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        Label {
            text: i18n("Enable, disable, and reorder session buttons:")
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            wrapMode: Text.Wrap
            opacity: 0.7
        }

        Repeater {
            model: buttonsModel

            ItemDelegate {
                id: btnDelegate
                Layout.fillWidth: true

                readonly property bool isHibernate: model.id === "hibernate"
                readonly property bool hibernateUnavailable: isHibernate && !sm.canHibernate

                highlighted: false
                hoverEnabled: true

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    CheckBox {
                        checked: model.enabled
                        enabled: !btnDelegate.hibernateUnavailable
                        onToggled: {
                            buttonsModel.setProperty(index, "enabled", checked)
                            saveButtons()
                        }
                    }

                    Kirigami.Icon {
                        source: buttonMeta[model.id] ? buttonMeta[model.id].icon : ""
                        Layout.preferredWidth: Kirigami.Units.iconSizes.small
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        opacity: btnDelegate.hibernateUnavailable ? 0.4 : 1.0
                    }

                    Label {
                        text: {
                            var label = buttonMeta[model.id] ? buttonMeta[model.id].label : model.id
                            if (btnDelegate.hibernateUnavailable)
                                return label + " " + i18n("(not available)")
                            return label
                        }
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        opacity: btnDelegate.hibernateUnavailable ? 0.4 : 1.0
                    }

                    ToolButton {
                        icon.name: "arrow-up"
                        enabled: index > 0
                        onClicked: {
                            buttonsModel.move(index, index - 1, 1)
                            saveButtons()
                        }
                    }

                    ToolButton {
                        icon.name: "arrow-down"
                        enabled: index < buttonsModel.count - 1
                        onClicked: {
                            buttonsModel.move(index, index + 1, 1)
                            saveButtons()
                        }
                    }
                }

                ToolTip.visible: hovered && btnDelegate.hibernateUnavailable
                ToolTip.text: i18n("Hibernation is not available on this system")
                ToolTip.delay: 500
            }
        }
    }
}
