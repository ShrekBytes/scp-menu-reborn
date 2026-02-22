# SCP Menu Reborn - for KDE Plasma 6.6+

<!-- <img src="screenshots/scp_menu_reborn.png" alt="SCP Menu Reborn logo" width="88px" /> -->

A clean, minimal KDE Plasma panel widget that provides a customizable power/session menu with app launcher shortcuts.

See it on the KDE Store: https://store.kde.org/p/2348938


## Features

- Configurable app launcher shortcuts
- **6 session buttons**: Lock Screen, Log Out, Restart, Sleep, Shut Down, Hibernate — each independently toggleable
- **Reorderable** session buttons and app launchers
- **Two-column or single-column** layout toggle for session buttons
- **Configurable button borders** for a more defined look (enabled by default)
- Customizable widget icon


## Screenshots

![SCP Menu Reborn](screenshots/preview.png)
![Config — General](screenshots/config-general.png)
![Config — Apps](screenshots/config-apps.png)


## Requirements

- KDE Plasma 6.6+
- KDE Frameworks 6
- Qt 6.x


## Installation

### Option 1: Install from Plasma widgets (recommended)

1. Open panel edit mode and choose **Add/Manage Widgets**.
2. Click **Get New…** → **Download New Plasma Widgets**.
3. Search for **"SCP Menu Reborn"**.
4. Click **Install** and add the widget to your panel.

### Option 2: Install from KDE Store download

1. Go to https://store.kde.org/p/2348938
2. Open the **Files** tab and download the *SCP Menu Reborn* `.plasmoid` file.
3. In Plasma, open **Add/Manage Widgets** → **Get New…** → **Install Widget From Local File**.
4. Select the downloaded `.plasmoid` file and complete the installation.

### Option 3: Install from source with kpackagetool6

```bash
git clone https://github.com/ShrekBytes/scp-menu-reborn.git
cd scp-menu-reborn
kpackagetool6 -t Plasma/Applet -i .
```

Restart plasmashell:

```bash
systemctl --user restart plasma-plasmashell
```

or log out and log back in.

### Upgrading an existing kpackagetool6 installation

From inside the project directory:

```bash
kpackagetool6 -t Plasma/Applet -u .
```

Then restart plasmashell again:

```bash
systemctl --user restart plasma-plasmashell
```

or log out and log back in.


### Uninstalling existing kpackagetool6 installation

```bash
kpackagetool6 -t Plasma/Applet -r org.kde.plasma.scpmr
```


## Acknowledgements

- Based on [SCP Menu](https://store.kde.org/p/2137217/) by **Dervart**
- [USwitch](https://gitlab.com/divinae/uswitch) by **diVinae**


## License

Licensed under the [**GNU General Public License v3.0**](LICENSE)
