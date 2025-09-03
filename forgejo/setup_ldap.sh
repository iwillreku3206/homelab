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

AD_DOMAIN_LOWER=`echo $AD_DOMAIN | awk '{print tolower($1)}'`

docker exec `docker ps -f name=forgejo* --format {{.ID}}` \
  forgejo admin auth add-ldap \
    --active \
    --name 'Active Directory' \
    --security-protocol 'StartTLS'\
    --skip-tls-verify \
    --host "${CORE_INTERNAL_IP}" \
    --port 389 \
    --user-search-base "DC=${AD_DOMAIN_LOWER},DC=rinaldolee,DC=com" \
    --user-filter "(&(objectClass=user)(sAMAccountName=%s)(|(memberOf=CN=Admins,CN=Users,DC=${AD_DOMAIN_LOWER},DC=rinaldolee,DC=com)(memberOf=CN=Family,CN=Users,DC=${AD_DOMAIN_LOWER},DC=rinaldolee,DC=com)(memberOf=CN=People,CN=Users,DC=${AD_DOMAIN_LOWER},DC=rinaldolee,DC=com)))" \
    --admin-filter "(&(objectClass=user)(sAMAccountName=%s)(memberOf=CN=Admins,CN=Users,DC=${AD_DOMAIN_LOWER},DC=rinaldolee,DC=com))" \
    --username-attribute 'sAMAccountName' \
    --firstname-attribute 'givenName' \
    --surname-attribute 'sn' \
    --email-attribute 'mail' \
