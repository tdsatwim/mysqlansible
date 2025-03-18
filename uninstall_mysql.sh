#!/bin/bash

echo "🚨 WARNING: This will completely remove MySQL and all its data! 🚨"
read -p "Are you sure you want to continue? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Aborting..."
    exit 1
fi

echo "📌 Stopping MySQL service..."
sudo systemctl stop mysqld

echo "📌 Disabling MySQL service..."
sudo systemctl disable mysqld

echo "📌 Uninstalling MySQL packages..."
sudo dnf remove -y mysql mysql-server mysql-client mysql-common mysql-devel mysql-libs

echo "📌 Removing MySQL dependencies..."
sudo dnf autoremove -y

echo "📌 Deleting MySQL data directory..."
sudo rm -rf /var/lib/mysql

echo "📌 Removing MySQL configuration files..."
sudo rm -f /etc/my.cnf
sudo rm -rf /etc/mysql

echo "📌 Deleting MySQL logs..."
sudo rm -rf /var/log/mysql*

echo "📌 Cleaning up package manager cache..."
sudo dnf clean all

echo "📌 Checking for leftover MySQL packages..."
leftover=$(dnf list installed | grep -i mysql)
if [[ -n "$leftover" ]]; then
    echo "⚠️ Some MySQL-related packages are still installed:"
    echo "$leftover"
else
    echo "✅ MySQL is completely removed!"
fi

echo "📌 Checking if MySQL service still exists..."
if systemctl list-units --type=service | grep -q "mysqld"; then
    echo "⚠️ MySQL service is still registered! You may need to reboot."
else
    echo "✅ MySQL service is fully removed!"
fi

echo "🎉 MySQL has been completely uninstalled!"
