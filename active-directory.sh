#!/usr/bin/env bash

read -s -p "Enter AD Admin Password: " AD_ADMIN_PASSWORD
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

samba-tool domain provision --use-rfc2307 --realm HOME2.RINALDOLEE.COM --domain HOME2 --server-role dc --dns-backend SAMBA_INTERNAL --admin-pass "$AD_ADMIN_PASSWORD" 
