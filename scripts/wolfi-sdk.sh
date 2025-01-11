#!/bin/sh

# Symlink distrobox shims
mkdir -p "/usr/local/bin"
./distrobox-shims.sh

# Update the container and install packages
apk update && apk upgrade
grep -v '^#' ./wolfi-sdk.packages | xargs apk add

# Fake pinentry for distrobox
# https://github.com/89luca89/distrobox/issues/1249
echo "#!/bin/sh" > /usr/bin/pinentry
echo "exit 0" >> /usr/bin/pinentry
chmod +x /usr/bin/pinentry

# Temp setup to go install handy utils
cd /tmp
export GOPATH="/tmp/go"
export PATH="${GOPATH}/bin:${PATH}"
mkdir -p "${GOPATH}"
mkdir -p "/usr/bin"

go install github.com/philroche/wolfi-package-status@latest
mv "${GOPATH}/bin/wolfi-package-status" "/usr/bin"
cd -
rm -rf /tmp/*

# Change root shell to BASH
sed -i -e '/^root/s/\/bin\/ash/\/bin\/bash/' /etc/passwd
