#!/usr/bin/env bash

set -e

apt-get install -y gpg samba krb5-config krb5-user

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

echo Writing /etc/resolv.conf
chattr -i /etc/resolv.conf
echo "nameserver $CORE_INTERNAL_IP" > /etc/resolv.conf
echo "search $(echo $AD_REALM | awk '{print tolower($0)}')" >> /etc/resolv.conf
chattr +i /etc/resolv.conf

echo Writing Kerberos Config

echo '[libdefaults]' > /etc/krb5.conf
echo "        default_realm = $AD_REALM" >> /etc/krb5.conf
echo '        dns_lookup_realm = false' >> /etc/krb5.conf
echo '        dns_lookup_kdc = true' >> /etc/krb5.conf
echo '        kdc_timesync = 1' >> /etc/krb5.conf
echo '        ccache_type = 4' >> /etc/krb5.conf
echo '        forwardable = true' >> /etc/krb5.conf
echo '        proxiable = true' >> /etc/krb5.conf
echo '        rdns = false' >> /etc/krb5.conf

echo Writing Samba Config
echo "[global]" > /etc/samba/smb.conf
echo "   log file = /var/log/samba/log.%m" >> /etc/samba/smb.conf
echo "   max log size = 1000" >> /etc/samba/smb.conf
echo "   logging = file" >> /etc/samba/smb.conf
echo "   panic action = /usr/share/samba/panic-action %d" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "   workgroup = $AD_DOMAIN" >> /etc/samba/smb.conf
echo "   security = ADS" >> /etc/samba/smb.conf
echo "   realm = $AD_REALM" >> /etc/samba/smb.conf
echo "   server role = member server" >> /etc/samba/smb.conf
echo "   obey pam restrictions = yes" >> /etc/samba/smb.conf
echo "   unix password sync = yes" >> /etc/samba/smb.conf
echo "   passwd program = /usr/bin/passwd %u" >> /etc/samba/smb.conf
echo "   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* ." >> /etc/samba/smb.conf
echo "   pam password change = yes" >> /etc/samba/smb.conf
echo "   map to guest = bad user" >> /etc/samba/smb.conf
echo "   username map = /etc/samba/user.map" >> /etc/samba/smb.conf
echo "   idmap config * : backend = tdb" >> /etc/samba/smb.conf
echo "   idmap config * : range = 3000-7999" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "   idmap config HOME2 : backend = ad" >> /etc/samba/smb.conf
echo "   idmap config HOME2 : range = 10000-999999" >> /etc/samba/smb.conf
echo "   idmap config HOME2 : schema_mode = rfc2307" >> /etc/samba/smb.conf
echo "   winbind nss info = rfc2307" >> /etc/samba/smb.conf
echo "   winbind use default domain = yes" >> /etc/samba/smb.conf
echo "   winbind enum users = yes" >> /etc/samba/smb.conf
echo "   winbind enum groups = yes" >> /etc/samba/smb.conf
echo "" >> /etc/samba/smb.conf
echo "   template shell = /bin/bash" >> /etc/samba/smb.conf
echo "   template homedir = /home/%U" >> /etc/samba/smb.conf
echo "   usershare allow guests = yes" >> /etc/samba/smb.conf

echo Writing user map
echo "!root = $AD_DOMAIN\Administrator" >> /etc/samba/user.map

echo Writing to /etc/hosts
echo "$APPS_INTERNAL_IP $(echo $APPS_HOSTNAME | awk '{print toupper($0)}').$AD_REALM   $(echo $APPS_HOSTNAME | awk '{print toupper($0)}')" >> /etc/hosts

echo Joining domain
samba-tool domain join $(echo $AD_REALM MEMBER | awk '{print tolower($0)}') -U administrator --password "$AD_ADMIN_PASSWORD"

echo Enabling services
systemctl enable --now smbd
systemctl enable --now nmbd
systemctl enable --now winbind

