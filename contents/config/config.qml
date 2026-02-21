import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-desktop-user"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Apps")
        icon: "view-app-grid-symbolic"
        source: "configApps.qml"
    }
}
