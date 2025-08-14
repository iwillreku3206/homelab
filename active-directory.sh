#!/usr/bin/env bash

read -s -p "Enter AD Admin Password: " AD_ADMIN_PASSWORD

if [[ -e /etc/samba/smb.conf ]]; do
  rm /etc/samba/smb.conf
fi
samba-tool domain provision --use-rfc2307 --realm HOME2.RINALDOLEE.COM --domain HOME2 --server-role dc --dns-backend SAMBA_INTERNAL --admin-pass "$AD_ADMIN_PASSWORD" 
