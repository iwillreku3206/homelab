set -e

export PATH="$PATH:/sbin:/usr/sbin:/usr/local/sbin"

if ! command -v forgejo >/dev/null 2>&1
then
  apt install -y wget apt-transport-https
  wget --content-disposition https://code.forgejo.org/forgejo-contrib/-/packages/debian/forgejo-deb-repo/0-0/files/10103
  dpkg -i forgejo-deb-repo_0-0_all.deb
  rm forgejo-deb-repo_0-0_all.deb
  apt update
  apt upgrade
  apt install -y forgejo-bin
fi


