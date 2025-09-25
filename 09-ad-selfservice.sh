#!/bin/bash

if [ -z "${BASE_FAST_DIR}" ]; then
  apt install -y gpg

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
fi

mkdir -p $BASE_FAST_DIR/ad-self-service

echo '' > $BASE_FAST_DIR/ad-self-service/config.inc.local.php

echo "<?php"
echo "	\$keyphrase = \"$AD_SELFSERVE_SECRET\";"
echo "	\$debug = true;"
echo "	\$ldap_url = \"ldap://$CORE_INTERNAL_IP\";"
echo "	#\$ldap_starttls = true;"
echo "	#putenv(\"LDAPTLS_REQCERT=allow\");"
echo "	#putenv(\"LDAPTLS_CACERT=/etc/ssl/certs/ca-certificates.crt\");"
echo "	\$ldap_binddn = \"cn=selfserve,dc=Users,dc=home,dc=rinaldolee,dc=com\";"
echo "	\$ldap_bindpw = '$AD_SELFSERVE_SECRET';"
echo "	\$ldap_base = \"dc=home,dc=rinaldolee,dc=com\";"
echo "	\$ldap_login_attribute = \"uid\";"
echo "?>"
