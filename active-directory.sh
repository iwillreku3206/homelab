#!/usr/bin/env bash

rm /etc/samba/smb.conf
samba-tool domain provision --use-rfc2307 --realm HOME2.RINALDOLEE.COM --domain HOME2 --server-role dc --dns-backend SAMBA_INTERNAL --admin-pass "$AD_ADMIN_PASSWORD" 
