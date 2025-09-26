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

mkdir -p $BASE_FAST_DIR/ad-self-service/config

echo '' > $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php

echo "<?php" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$keyphrase = \"$AD_SELFSERVE_SECRET\";" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$debug = true;" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$ldap_url = \"ldap://$CORE_INTERNAL_IP\";" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$ldap_starttls = true;" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	putenv(\"LDAPTLS_REQCERT=never\");" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	//putenv(\"LDAPTLS_CACERT=/etc/ssl/certs/ca-certificates.crt\");" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$ldap_binddn = \"selfserve@home.rinaldolee.com\";" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$ldap_bindpw = '$AD_SELFSERVE_PASSWORD';" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$ldap_base = \"dc=home,dc=rinaldolee,dc=com\";" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$ldap_login_attribute = \"uid\";" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$use_captcha = true;" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$captcha_class = \"InternalCaptcha\";" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$cache_type = \"Redis\";" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$cache_redis_url = \"redis:redis.redis:6379\";" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$cache_namespace = \"adsspCache\";" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$cache_default_lifetime = 0;" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$ad_mode = true;" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "	\$ldap_filter = \"(&(objectClass=user)(sAMAccountName={login})(!(userAccountControl:1.2.840.113556.1.4.803:=2)))\";" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
echo "?>" >> $BASE_FAST_DIR/ad-self-service/config/config.inc.local.php
