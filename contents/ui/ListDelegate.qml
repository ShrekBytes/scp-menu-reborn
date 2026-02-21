import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.ItemDelegate {
    id: item

    Layout.fillWidth: true

    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing
    leftPadding: Kirigami.Units.largeSpacing
    rightPadding: Kirigami.Units.largeSpacing

    property alias iconItem: iconItem.children

    Accessible.name: `${text}`

    background: Rectangle {
        radius: Kirigami.Units.smallSpacing
        color: item.hovered ? Kirigami.Theme.hoverColor : "transparent"
        opacity: item.hovered ? 0.15 : 1.0
    }

    contentItem: RowLayout {
        id: row

        spacing: Kirigami.Units.smallSpacing

        Item {
            id: iconItem

            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            Layout.minimumWidth: Layout.preferredWidth
            Layout.maximumWidth: Layout.preferredWidth
            Layout.minimumHeight: Layout.preferredHeight
            Layout.maximumHeight: Layout.preferredHeight
        }

        ColumnLayout {
            id: column
            Layout.fillWidth: true
            spacing: 0

            PlasmaComponents.Label {
                id: label
                Layout.fillWidth: true
                text: item.text
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }
        }
    }
}
