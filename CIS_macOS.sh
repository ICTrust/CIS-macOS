####################################################
# Description: CIS v8 automation for macOS
# Version: 0.1
# Author: A-YATTA (Amine T.)
# Organisation: ICTrust
# Tests: Tested on macOS Monterey 12 (M1 and Intel).
# Date: 27.09.2022
# LICENSE: MIT
####################################################

# Enable debugging by uncommenting the line bellow
#set -x



# Variables
## Organisation info
org="ICTrust"
org_contact="hello@ictrust.ch"
ntp="pool.ntp.org"
timezone="Europe/Zurich"

## Messages 
login_screen_msg="If you found this laptop please let $org know at $org_contact. A rewards will be provided.\nSi vous trouvez cet ordinateur, veuillez s'il vous plait contacter $org à $org_contact. Une récomponse sera attribuée."
login_window_banner="* * * * * * * * * * W A R N I N G * * * * * * * * * *
UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED
You must have explicit, authorized permission to access or configure this device. Unauthorized attempts and actions to access or use this system may result in civil and/or criminal penalties. All activities performed on this device are logged and monitored

L'ACCÈS NON AUTORISÉ À CET APPAREIL EST INTERDIT
Vous devez avoir la permission explicite et autorisée d'accéder à cet appareil ou de le configurer. Les tentatives et actions non autorisées d'accès ou d'utilisation de ce système peuvent entraîner des sanctions civiles et/ou pénales. Toutes les activités effectuées sur cet appareil sont enregistrées et contrôlées.
* * * * * * * * * * * * * * * * * * * * * * * *"

# Printing
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    printf "${GREEN}$1 ${NC}\n"
}

print_info() {
    printf "${BLUE}[INFO] $1 ${NC}\n"
}

print_fail() {
    printf "${RED}[ERROR] $1 ${NC}\n"
}


print_warn() {
    printf "${RED}[WARNING] $1 ${NC}\n"
}

# List of current users
users_list=$(dscacheutil -q user | grep -A 3 -B 2 -e uid:\ 5'[0-9][0-9]' | grep name | cut -d' ' -f2)

################################################
# 1.1 Verify all Apple-provided software is current
################################################
print_info "Check for system updates"
updates=$(softwareupdate -l 2>&1 | grep "No new software available.")

if [[ $updates =~ "No new software"* ]]; then
    print_success "No software updates available\n"
else 
    print_fail "System updates are available\n"
    read -p "Do you wish to install the updates?" yn
    case $yn in
        [Yy]* ) softwareupdate -i -a; break;;
        [Nn]* ) continue;;
        * ) echo "Please answer yes or no.";;
    esac
fi

################################################
# 1.2 Enable Auto Update
################################################
print_info "Enable automatic updates"
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -int true

################################################
# 1.3 Enable Download new updates when available
################################################
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true


################################################
# 1.4 Enable app update installs 
################################################
print_info "Enable Download new updates when available"
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true


################################################
# 1.4 Enable system data files and security updates install 
################################################
print_info "Enable system data files and security updates install"
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true


################################################
# 1.4 Enable macOS update installs
################################################
print_info "Enable system data files and security updates install"
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool true

################################################
# 2 System Preferences
################################################

################################################
# 2.1 Bluetooth
################################################
# Skipped

################################################
# 2.2.1 Enable "Set time and date automatically"
################################################
sudo systemsetup -setnetworktimeserver $ntp
print_info "Enable automatic date and time: $ntp"
sudo systemsetup -settimezone $timezone
sudo systemsetup -setusingnetworktime on 

################################################
# 2.2.2 Ensure time set is within appropriate limits
################################################
# TO-DO

################################################
# 2.3 Desktop & Screen Saver
################################################
################################################
# 2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver
################################################
print_info "Set inactivity interval to 10 minutes"
sudo defaults -currentHost write com.apple.screensaver idleTime -int 600 2> /dev/null

################################################
# 2.3.2 Secure screen saver corners
################################################
# By default (on macos 12.x) the value does not exist which is compliant

################################################
# 2.4.1 Disable Remote Apple Events
################################################
print_info "Disable Remote Apple Events"
sudo systemsetup -setremoteappleevents off 2> /dev/null

################################################
# 2.4.2 Disable Internet Sharing
################################################
print_info "Disable Internet Sharing"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.nat NAT -dict Enabled -int 0 2> /dev/null


################################################
# 2.4.3 Disable Screen Sharing
################################################
print_info "Disable screen sharing"
sudo launchctl disable system/com.apple.screensharing 2> /dev/null 

################################################
# 2.4.4 Disable Printer Sharing 
################################################
print_info "Disable printer sharing"
sudo cupsctl --no-share-printers 2> /dev/null  

################################################
# 2.4.5 Disable Remote Login 
################################################
print_info "Disable remote login"
sudo systemsetup -setremotelogin off 2> /dev/null

################################################
# 2.4.6 Disable DVD or CD Sharing 
################################################
print_info "Disable DVD or CD Sharing"
sudo launchctl disable system/com.apple.ODSAgent 2> /dev/null

################################################
# 2.4.7 Disable Bluetooth Sharing
################################################
print_info "Disable Bluetooth Sharing for all users"
for user in $users_list; do
    sudo -u "$user" defaults -currentHost write com.apple.Bluetooth PrefKeyServicesEnabled -bool false 2> /dev/null
done

################################################
# 2.4.8 Disable File Sharing
################################################
print_info "Disable file sharing"
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist 2> /dev/null

################################################
# 2.4.9 Disable Remote Management
################################################
print_info "Disable remote management"
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources /kickstart -deactivate -stop 2> /dev/null

################################################
# 2.4.10 Disable Content Caching
################################################
print_info "Disable content caching"
sudo AssetCacheManagerUtil deactivate 2> /dev/null

################################################
# 2.4.11 Disable Media Sharing
################################################
print_info "Disable Media Sharing"
for user in $users_list; do
    sudo -u "$user" defaults write com.apple.amp.mediasharingd home-sharing-enabled -int 0 2> /dev/null
done

################################################
# 2.4.12 Ensure AirDrop Is Disabled
################################################
print_info "Disable AirDrop"
for user in $users_list; do
    sudo -u "$user" defaults write com.apple.NetworkBrowser DisableAirDrop -bool true 2> /dev/null
done

################################################
# 2.5 Security & Privacy
################################################
################################################
# 2.5.1 Encryption
################################################
################################################
# 2.5.1.1 Enable FileVault
################################################
print_info "Check if FileVault is enabled"
filevault_status=$(sudo fdesetup status)
if [[ $filevault_status == "FileVault is On." ]]; then
    print_success "FileVault is enabled"
else 
    print_fail "FileVault is disabled"
fi

################################################
# 2.5.2 Firewall 
################################################
################################################
# 2.5.2.1 Enable Gatekeeper
################################################
print_info "Enable Gatekeeper"
sudo spctl --master-enable 2> /dev/null

################################################
# 2.5.2.1 Enable Firewall
################################################
print_info "Enable Firewall"
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 2 2> /dev/null
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

################################################
# 2.5.2.3 Enable Firewall Stealth Mode
################################################
print_info "Enable Stealth Mode"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on


################################################
# 2.5.3 Enable Location Services
################################################
# Skipped 

################################################
# 2.5.5 Disable sending diagnostic and usage data to Apple
################################################
print_info "Disable sending diagnostic and usage data to Apple"
sudo defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool false 2> /dev/null
sudo chmod 644 /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist 2> /dev/null
sudo chgrp admin /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist 2> /dev/null

################################################
# 2.5.6 Limit Ad tracking and personalized Ads
################################################
print_info "Limit Ad tracking and personalized Ads"
for user in $users_list; do
    sudo -u "$user" defaults -currentHost write /Users/"$user"/Library/Preferences/com.apple.Adlib.plist allowApplePersonalizedAdvertising -bool false 2> /dev/null
done

################################################
# 2.6.1 iCloud configuration
################################################
# TO-DO 

################################################
# 2.7 Time Machine
################################################
# TO-DO

################################################
# 2.8 Disable Wake for network access 
################################################
print_info "Disable Wake for network access"
sudo pmset -a womp 0 2> /dev/null 

################################################
# 2.9 Disable Power Nap
################################################
print_info "Disable Power Nap"
sudo pmset -a powernap 0

################################################
# 2.10 Enable Secure Keyboard Entry in terminal.app
################################################
print_info "Enable Secure Keyboard Entry in terminal.app"
for user in $users_list; do
    sudo -u "$user" defaults write -app Terminal SecureKeyboardEntry -bool true 2> /dev/null
done

################################################
# 2.11 Ensure EFI version is valid and being regularly checked
################################################
# TO-DO 

################################################
# 2.12 Automatic Actions for Optical Media 
################################################
# TO-DO 

################################################
# 2.13 Review Siri Settings
################################################
print_info "Disable Siri"
for user in $users_list; do
    sudo -u "$user" defaults write com.apple.assistant.support.plist 'Assistant Enabled' -bool false 2> /dev/null
    sudo -u "$user" defaults write com.apple.Siri.plist LockscreenEnabled -bool false 2> /dev/null
    sudo -u "$user" defaults write com.apple.Siri.plist StatusMenuVisible -bool false 2> /dev/null
    sudo -u "$user" defaults write com.apple.Siri.plist VoiceTriggerUserEnabled -bool false 2> /dev/null
done
 
# Restart the Windows Server and clear the caches
sudo killall -HUP cfprefsd
sudo killall SystemUIServer

################################################
# 3 Logging and Auditing
################################################
################################################
# 3.1 Enable security auditing 
################################################
print_info "Enable security auditing "
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist 2> /dev/null

################################################
# 3.2 Configure Security Auditing Flags per local organizational requirements
################################################
print_info "Set auditing flags to 'all'"
sudo sed -i.bu "s/^flags:.*/flags:all/g" /etc/security/audit_control 2> /dev/null 

################################################
# 3.3 Retain install.log for 365 or more days with no maximum sizes
################################################
print_info "Retain install.log for 365 days"
sudo sed -i.bu '$s/$/ ttl=365/' /etc/asl/com.apple.install
print_info "Set maximum size to 1G"
sudo sed -i.bu 's/all_max=[0-9]*[mMgG]/all_max=1G/g' /etc/asl/com.apple.install

################################################
# 3.4 Ensure security auditing retention
################################################
print_info "Set audit records expiration to 1 gigabyte"
sudo sed -i.bu "s/^expire-after:.*/expire-after:1G/g" /etc/security/audit_control

################################################
# 3.5 Control access to audit records
################################################
print_info "Set the audit records to the root user and wheel group"
sudo chown -R root:wheel /etc/security/audit_control 2> /dev/null
sudo chmod -R -o-rw /etc/security/audit_control 2> /dev/null
sudo chown -R root:wheel /var/audit/ 2> /dev/null
sudo chmod -R -o-rw /var/audit/ 2> /dev/null

################################################
# 3.6 Ensure Firewall is configured to log
################################################
print_info "Enable firewall logging mode"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on

################################################
# 3.7 Software Inventory Considerations
################################################
# TO-DO 


################################################
# 4 Network Configurations
################################################
################################################
# 4.1 Disable Bonjour advertising service
################################################
print_info "Enable firewall logging mode"
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true

################################################
# 4.2 Enable "Show Wi-Fi status in menu bar"
################################################
print_info "Enable 'Show Wi-Fi status in menu bar' for all users" 
for user in $users_list; do
    sudo -u "$user" defaults -currentHost write com.apple.controlcenter.plist WiFi -int 18
done

################################################
# 4.3 Create network specific locations
################################################
# Skipped 

################################################
# 4.4 Ensure http server is not running
################################################
print_info "Disabling and shuting down http server"
sudo apachectl stop
sudo defaults write /System/Library/LaunchDaemons/org.apache.httpd Disabled -bool true


################################################
# 4.5 Ensure nfs server is not running
################################################
print_info "Disabling NFS server"
sudo launchctl disable system/com.apple.nfsd
sudo rm /etc/exports

################################################
# 4.6 Review Wi-Fi Settings
################################################
# Skipped

################################################
# 5 System Access, Authentication and Authorization
################################################
################################################
# 5.1 File System Permissions and Access Controls
################################################

################################################
# 5.1.1 Secure Home Folders 
################################################
print_info "Securing home folders"
for user in $users_list; do
    sudo chmod -R og-rwx /Users/"$user" 2> /dev/null
done
 
################################################
# 5.1.2 Check System Wide Applications for appropriate permissions
################################################
# Skipped 

################################################
# 5.1.3 Check System folder for world writable files
################################################
# Skipped 

################################################
# 5.1.4 Check Library folder for world writable files
################################################
# TO-DO 

################################################
# 5.2 Password Management
################################################
################################################
# 5.2.1 Configure account lockout threshold
###############################################
print_info "Settings maximum failed login attempts to 5 before locking the account"
sudo pwpolicy -n /Local/Default -setglobalpolicy "maxFailedLoginAttempts=5"

################################################
# 5.2.2 Set a minimum password length 
###############################################
print_info "Settings minimum password length to 15"
sudo pwpolicy -n /Local/Default -setglobalpolicy "minChars=15"

################################################
# 5.2.3 Complex passwords must contain an Alphabetic Character
###############################################
print_info "Set password policy: must contain an Alphabetic Character"
sudo pwpolicy -n /Local/Default -setglobalpolicy "requiresAlpha=1"

################################################
# 5.2.4 Complex passwords must contain a Numeric Character 
###############################################
print_info "Set password policy: must contain an Alphabetic Character"
sudo pwpolicy -n /Local/Default -setglobalpolicy "requiresAlpha=1"

################################################
# 5.2.4 Complex passwords must contain a Numeric Character 
###############################################
print_info "Set password policy: must contain an Numeric Character"
sudo pwpolicy -n /Local/Default -setglobalpolicy "requiresNumeric=1"

################################################
# 5.2.5 Complex passwords must contain a Special Character
###############################################
print_info "Set password policy: must contain an Special Character"
sudo pwpolicy -n /Local/Default -setglobalpolicy "requiresSymbol=1"

################################################
# 5.2.6 Complex passwords must contain uppercase and lowercase letters
###############################################
print_info "Set password policy: must contain uppercase and lowercase letters"
sudo pwpolicy -n /Local/Default -setglobalpolicy "requiresMixedCase=1"

################################################
# 5.2.7 Password Age
###############################################
print_info "Set password expiration to 365 days"
sudo pwpolicy -n /Local/Default -setglobalpolicy "maxMinutesUntilChangePassword=525600"

################################################
# 5.2.8 Password History 
###############################################
print_info "Set password policy: must to be different from at least the last 15 passwords"
sudo pwpolicy -n /Local/Default -setglobalpolicy "usingHistory=15"

################################################
# 5.3 Reduce the sudo timeout period
################################################ 
print_info "Reduce sudo timeout period to 0"
timestamp_exist=$(sudo grep "timestamp_timeout" /etc/sudoers)
if [[ $timestamp_exist ]]; then
   sudo sed -i.bu "s/timestamp_timeout=[0-9]*/timestamp_timeout=0/g"  /etc/sudoers
else
    echo "Defaults timestamp_timeout=0" | sudo tee -a /etc/sudoers
fi

################################################
# 5.4 Automatically lock the login keychain for inactivity
################################################
print_info "Set automatic keychain lock after 6 hours"
for user in $users_list; do
    print_info "User: $user"
    sudo -u "$user" security unlock-keychain /Users/"$user"/Library/Keychains/login.keychain
    sudo -u "$user" security set-keychain-settings -t 21600 /Users/"$user"/Library/Keychains/login.keychain
done

################################################
# 5.5 Use a separate timestamp for each user/tty comboy
################################################
# TO-DO 

################################################
# 5.6 Ensure login keychain is locked when the computer sleeps
################################################
print_info "Lock keychain when the computer sleeps"
for user in $users_list; do
    print_info "User: $user"
    sudo -u "$user" security unlock-keychain /Users/"$user"/Library/Keychains/login.keychain
    sudo -u "$user" security set-keychain-settings -l /Users/"$user"/Library/Keychains/login.keychain
done

################################################
# 5.7 Do not enable the "root" account
################################################
# Skipped

################################################
# 5.8 Disable automatic login
################################################
print_info "Disable automatic login"
sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser

################################################
# 5.9 Require a password to wake the computer from sleep or screen saver
################################################
print_info "Enable require password to wake the computer from sleep or screen saver"
for user in $users_list; do
    sudo -u "$user" defaults write /Users/"$user"/Library/Preferences/com.apple.screensaver askForPassword -int 1
done

################################################
# 5.10 Ensure system is set to hibernate
################################################
print_info "Set the hibernate delays and to ensure the FileVault keys are set to be destroyed on standby"
sudo pmset -a standbydelayhigh 600
sudo pmset -a standbydelaylow 600
sudo pmset -a highstandbythreshold 90
sudo pmset -a destroyfvkeyonstandby 1

################################################
# 5.11 Require an administrator password to access system-wide preferences
################################################
print_info "Enable administrator password requirement to access system-wide preferences"
security authorizationdb read system.preferences > /tmp/system.preferences.plist
/usr/libexec/PlistBuddy -c "Set :shared false" /tmp/system.preferences.plist
security authorizationdb write system.preferences < /tmp/system.preferences.plist

################################################
# 5.12 Ensure an administrator account cannot login to another user's active and locked session
################################################
print_info "Ensure an administrator account cannot login to another user's active and locked session"
sudo security authorizationdb write system.login.screensaver use-login-window-ui

################################################
# 5.13 Create a custom message for the Login Screen
################################################ 
print_info "Add login screen message: $login_screen_msg"
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "$login_screen_msg"

################################################
# 5.14 Create a Login window banner
################################################
print_info "Add login window banner"
echo "$login_window_banner" | sudo tee /Library/Security/PolicyBanner.txt
sudo chmod 755 "/Library/Security/PolicyBanner."*  2> /dev/null

################################################
# 5.15 Do not enter a password-related hint
################################################
print_info "Delete password-related hint of all users if exist"
for user in $users_list; do
    sudo dscl . -delete /Users/$user hint
done

################################################
# 5.16 Disable Fast User Switching
################################################
print_info "Disable fast user switching"
sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool false

################################################
# 5.17 Secure individual keychains and items
################################################
# TO-DO

################################################
# 5.18 System Integrity Protection status
################################################
print_info "Enable system integrity protection"
sudo /usr/bin/csrutil enable

################################################
# 5.19 Enable Sealed System Volume
################################################
print_info "Enable sealed system volume"
sudo /usr/bin/csrutil enable authenticated-root

################################################
# 5.20 Enable Library Validation
################################################
print_info "Enable library validation"
sudo defaults write /Library/Preferences/com.apple.security.libraryvalidation.plist DisableLibraryValidation -bool false

################################################
# 6 User Accounts and Environment
# 6.1 Accounts Preferences Action Items
# 6.1.1 Display login window as name and password
################################################
print_info "Display login window as name and password"
sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

################################################
# 6.1.2 Disable "Show password hints"
################################################
print_info "Disable 'Show password hints'"
sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0

################################################
# 6.1.3 Disable guest account login
################################################
print_info "Disable guest account login"
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

################################################
# 6.1.4 Disable "Allow guests to connect to shared folders"
################################################
print_info "Disable 'Allow guests to connect to shared folders'"
sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool false
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false

################################################
# 6.1.5 Remove Guest home folder 
################################################
print_info "Remove Guest home folder if exist"
sudo rm -R /Users/Guest 2> /dev/null

################################################
# 6.2 Turn on filename extensions
################################################
print_info "Turn on filename extensions"
for user in $users_list; do
    sudo -u "$user" defaults write /Users/"$user"/Library/Prefjrences/.GlobalPreferences.plist AppleShowAllExtensions -bool true
done

################################################
# 6.3 Disable the automatic run of safe files in Safari
################################################
print_info "Disable the automatic run of safe files in Safari"
for user in $users_list; do
    sudo -u "$user" defaults write /Users/$user/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads -bool false
done

# Disable debugging
set +x