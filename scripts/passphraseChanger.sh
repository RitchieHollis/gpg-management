#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Error: only root can run the script. Type sudo bash $0 <file name> <current passphrase>"
    exit 1
fi

if [ "$#" -lt 2 ]; then
    echo "Usage: sudo bash $0 <file name> <current passphrase>"
    exit 1
fi

file=$1
decryptedFile="df"
newFile=$1
oldPassphrase=$2

gpg --batch --yes --passphrase "$oldPassphrase" -d -o "$decryptedFile" "$file"

if [ $? -ne 0 ]; then
    echo "Decryption failed"
    shred -u "$decryptedFile"
    exit 1
fi

newPassphrase=$(openssl rand -base64 16)
echo "New passphrase: $newPassphrase"
echo "Save this passphrase securely. WARNING: proceeding will clear the current terminal"

while true; do
    read -p "Done? (y)" confirmation
    if [ "$confirmation" == "y" ]; then
        clear
        break
    else
        echo "Invalid input"
    fi
done

gpg --batch --yes --passphrase "$newPassphrase" -c -o "$newFile" "$decryptedFile"
shred -u "$decryptedFile"

echo "Updating the local database..."
updatedb

echo "File has been encrypted with a new passphrase"
