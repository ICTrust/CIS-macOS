## CIS-macOS
CIS compliance script for macOS

> Please read more about [CIS benchmarks](https://www.cisecurity.org/cis-benchmarks/) before running the script

## Why?
The main goal is to help macOS users and sysAdmins to secure their system.


## How ? 
- Clone this repository:
```
git clone https://github.com/ICTrust/CIS-macOS.git
cd CIS-macOS
```

- Edit the variable in `CIS_macOS.sh` at your convenience :

```
# Variables
## Organisation info
org="ICTrust" 
org_contact="hello@ictrust.ch"
ntp="pool.ntp.org"
timezone="Europe/Zurich"

login_screen_msg="If you found this laptop please let $org know at $org_contact. A rewards will be provided.\nSi vous trouvez cet ordinateur, veuillez s'il vous plait contacter $org à $org_contact. Une récomponse sera attribuée."
login_window_banner="* * * * * * * * * * W A R N I N G * * * * * * * * * *
UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED
You must have explicit, authorized permission to access or configure this device. Unauthorized attempts and actions to access or use this system may result in civil and/or criminal penalties. All activities performed on this device are logged and monitored

L'ACCÈS NON AUTORISÉ À CET APPAREIL EST INTERDIT
Vous devez avoir la permission explicite et autorisée d'accéder à cet appareil ou de le configurer. Les tentatives et actions non autorisées d'accès ou d'utilisation de ce système peuvent entraîner des sanctions civiles et/ou pénales. Toutes les activités effectuées sur cet appareil sont enregistrées et contrôlées.
* * * * * * * * * * * * * * * * * * * * * * * *"
````

- Execute the script with root privileges: 
```
sudo sh CIS_macOS.sh
``` 

## Result

CIS hardened macOS.

## Implementation
* 1.1 Verify all Apple-provided software is current
* 1.2 Enable Auto Update
* 1.3 Enable Download new updates when available
* 1.4 Enable app update installs
* 1.4 Enable system data files and security updates install
* 1.4 Enable macOS update installs
* 2 System Preferences
* 2.1 Bluetooth
  - Skipped
* 2.2.1 Enable "Set time and date automatically"
* 2.2.2 Ensure time set is within appropriate limits
* 2.3 Desktop & Screen Saver
* 2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver
* 2.3.2 Secure screen saver corners
* By default (on macos 12.x) the value does not exist which is compliant
* 2.4.1 Disable Remote Apple Events
* 2.4.2 Disable Internet Sharing
* 2.4.3 Disable Screen Sharing
* 2.4.4 Disable Printer Sharing
* 2.4.5 Disable Remote Login
* 2.4.6 Disable DVD or CD Sharing
* 2.4.7 Disable Bluetooth Sharing
* 2.4.8 Disable File Sharing
* 2.4.9 Disable Remote Management
* 2.4.10 Disable Content Caching
* 2.4.11 Disable Media Sharing
* 2.4.12 Ensure AirDrop Is Disabled
* 2.5 Security & Privacy
* 2.5.1 Encryption
* 2.5.1.1 Enable FileVault
* 2.5.2 Firewall
* 2.5.2.1 Enable Gatekeeper
* 2.5.2.1 Enable Firewall
* 2.5.2.3 Enable Firewall Stealth Mode
* 2.5.3 Enable Location Services
  - Skipped
* 2.5.5 Disable sending diagnostic and usage data to Apple
* 2.5.6 Limit Ad tracking and personalized Ads
* 2.6.1 iCloud configuration
* 2.7 Time Machine
* 2.8 Disable Wake for network access
* 2.9 Disable Power Nap
* 2.10 Enable Secure Keyboard Entry in terminal.app
* 2.11 Ensure EFI version is valid and being regularly checked
* 2.12 Automatic Actions for Optical Media
* 2.13 Review Siri Settings
* 3 Logging and Auditing
* 3.2 Configure Security Auditing Flags per local organizational requirements
* 3.3 Retain install.log for 365 or more days with no maximum sizes
* 3.4 Ensure security auditing retention
* 3.5 Control access to audit records
* 3.6 Ensure Firewall is configured to log
* 3.7 Software Inventory Considerations
* 4 Network Configurations
* 4.1 Disable Bonjour advertising service
* 4.2 Enable "Show Wi-Fi status in menu bar"
* 4.3 Create network specific locations
  - Skipped
* 4.4 Ensure http server is not running
* 4.5 Ensure nfs server is not running
* 4.6 Review Wi-Fi Settings
  - Skipped
* 5 System Access, Authentication and Authorization
* 5.1 File System Permissions and Access Controls
* 5.1.1 Secure Home Folders
* 5.1.2 Check System Wide Applications for appropriate permissions
  - Skipped
* 5.1.3 Check System folder for world writable files
  - Skipped
* 5.1.4 Check Library folder for world writable files
* 5.2 Password Management
* 5.2.1 Configure account lockout threshold
* 5.2.2 Set a minimum password length
* 5.2.3 Complex passwords must contain an Alphabetic Character
* 5.2.4 Complex passwords must contain a Numeric Character
* 5.2.4 Complex passwords must contain a Numeric Character
* 5.2.5 Complex passwords must contain a Special Character
* 5.2.6 Complex passwords must contain uppercase and lowercase letters
* 5.2.7 Password Age
* 5.2.8 Password History
* 5.3 Reduce the sudo timeout period
* 5.4 Automatically lock the login keychain for inactivity
* 5.5 Use a separate timestamp for each user/tty comboy
* 5.6 Ensure login keychain is locked when the computer sleeps
* 5.7 Do not enable the "root" account
  - Skipped
* 5.8 Disable automatic login
* 5.9 Require a password to wake the computer from sleep or screen saver
* 5.10 Ensure system is set to hibernate
* 5.11 Require an administrator password to access system-wide preferences
* 5.12 Ensure an administrator account cannot login to another user's active and locked session
* 5.13 Create a custom message for the Login Screen
* 5.14 Create a Login window banner
* 5.15 Do not enter a password-related hint
* 5.16 Disable Fast User Switching
* 5.17 Secure individual keychains and items
* 5.18 System Integrity Protection status
* 5.19 Enable Sealed System Volume
* 5.20 Enable Library Validation
* 6 User Accounts and Environment
* 6.1 Accounts Preferences Action Items
* 6.1.1 Display login window as name and password
* 6.1.2 Disable "Show password hints"
* 6.1.3 Disable guest account login
* 6.1.4 Disable "Allow guests to connect to shared folders"
* 6.1.5 Remove Guest home folder
* 6.2 Turn on filename extensions
* 6.3 Disable the automatic run of safe files in Safari