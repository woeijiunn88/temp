#! /bin/sh

# Write a list of packages currently installed or read that list,
# presumably after a firmware upgrade, in order to reinstall all packages
# on that list not currently installed
#
# (c) 2013 Malte Forkel <malte.forkel@berlin.de>
#
# Originally found on OpenWrt forums at:
#    https://forum.openwrt.org/viewtopic.php?pid=194478#p194478
# Thanks, too, to hnyman for important comments on this script
#
# Version history
#    0.2.2 - editorial tweaks to help text -richb-hanvover 
#    0.3.0 - Converted to apk package manager

# Path to the list of installed packages
PACKAGE_LIST=/etc/config/installed_packages.list

# Function to save the list of currently installed packages
save_packages() {
    echo "Saving list of installed packages to $PACKAGE_LIST..."
    apk info > "$PACKAGE_LIST"
    echo "Package list saved successfully."
}

# Function to install missing packages from the saved list
install_packages() {
    if [ ! -f "$PACKAGE_LIST" ]; then
        echo "Package list $PACKAGE_LIST not found. Please save it first." >&2
        exit 1
    fi

    echo "Installing packages from $PACKAGE_LIST..."
    while read -r package; do
        # Strip version information if present (e.g., 'package-name - version')
        clean_package=$(echo "$package" | awk '{print $1}')
        echo "Installing $clean_package..."
        apk add "$clean_package"
    done < "$PACKAGE_LIST"
}

# Help message
show_help() {
    cat <<EOF
Usage: $0 [command]

Commands:
  save       Save the list of installed packages
  install    Install packages from the saved list
  help       Show this help message

Examples:
  $0 save
  $0 install
EOF
}

# Main script logic
case "$1" in
    save)
        save_packages
        ;;
    install)
        install_packages
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        echo "Invalid command. Use 'help' for usage." >&2
        exit 1
        ;;
esac
