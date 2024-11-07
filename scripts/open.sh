#!/bin/bash

if [ "$EUID" -ne 0 ]; then
        echo "Error, only root can run the script. Type sudo bash $0 <file name> <passphrase>"
        exit 1
fi

if [ "$#" -lt 2 ]; then
        echo "Usage: sudo bash $0 <file name> <current passphrase>"
        exit 1
fi

file=$1
passphrase=$2

temp="df"

gpg --batch --yes --passphrase "$passphrase" -d -o "$temp" "$file"

if [ $? -ne 0 ]; then
        echo "Decryption failed"
        shred -u "$temp"
        exit 1
fi

vi "$temp"

if [ $? -eq 0 ]; then
        gpg --batch --yes --passphrase "$passphrase" -c -o "$file" "$temp"
        confirmation=""
        while [ "${confirmation,,}" != 'y' ] && [ "${confirmation,,}" != 'n' ]; do
                read -p "For extra security, do you want to change the passphrase? (y/n)" confirmation
        done
        if [ "${confirmation,,}" == 'y' ]; then
                bash /usr/local/bin/passphraseChanger.sh $file $passphrase
                exit 1
        fi
fi

shred -u "$temp"
echo "File has been re-encrypted successfully"
