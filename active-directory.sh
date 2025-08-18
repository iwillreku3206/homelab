#!/usr/bin/env bash

set -e

apt-get install -y acl attr gpg samba winbind libpam-winbind libnss-winbind krb5-config krb5-user dnsutils python3-setproctitle

read -s -p "Enter ENV Password: " GPG_PASS

gpg --batch --yes --decrypt \
    --passphrase "$GPG_PASS" \
    --cipher-algo AES256 \
    -o .env \
    env

set -a
source .env
set +a

rm .env

read -s -p "Enter AD Admin Password: " AD_ADMIN_PASSWORD
echo
read -s -p "Confirm AD Admin Password: " AD_ADMIN_PASSWORD_CONFIRM

if [ "$AD_ADMIN_PASSWORD" != "$AD_ADMIN_PASSWORD_CONFIRM" ]; then
    echo "Error: Passwords do not match." >&2
    exit 1
fi

if [ -z "$AD_ADMIN_PASSWORD" ] || [ -z "$AD_ADMIN_PASSWORD_CONFIRM" ]; then
    echo "Error: Password fields cannot be empty." >&2
    exit 1
fi

if [[ -e /etc/samba/smb.conf ]]; then
  rm /etc/samba/smb.conf
fi

samba-tool domain provision --use-rfc2307 --realm "$AD_REALM" --domain "$AD_DOMAIN" --server-role dc --dns-backend SAMBA_INTERNAL --adminpass "$AD_ADMIN_PASSWORD" 

echo Updating /etc/hosts
echo "$CORE_INTERNAL_IP DC1.$AD_REALM   DC1" >> /etc/hosts
echo "$CORE_INTERNAL_IP $AD_DOMAIN" >> /etc/hosts
echo "$CORE_INTERNAL_IP $(echo $AD_REALM | awk '{print tolower($0)}')" >> /etc/hosts
