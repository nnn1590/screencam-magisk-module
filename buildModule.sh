#!/bin/bash

# Enable glob and disable history expansion
set +fH

[ "${#}" -le "1" ] && { echo "Usage: ${0} flavour version [SigningKey] [SigningKeyAlias]"; echo "Example: ${0} fdroid 2.0.3 ~/android-release-key.keystore key0"; exit; }
# Env variables
flavour="${1}"
version="${2}"
[ ! "x${3}X" = "xX" ] && SigningKey="${3}"
[ ! "x${4}X" = "xX" ] && SigningKeyAlias="${4}"
file="ScreenCam-Magisk-V${version}-${flavour}"

read -sp "Enter Keystore Password: " keyPass; echo
read -sp "Enter Alias Password. Leave empty to use keystore password: " aliasPass
[ "x${aliasPass}X" = "xX" ] && aliasPass="${keyPass}"

echo
echo Zipping module....
echo
#7z a -tzip "temp/${file}.zip" * "-xr!.*" "-xr!Releases" "-xr!temp" "-x!buildModule.sh" "-x!*.bat" "-x!*.zip" "-x!system/priv-app/ScreenCam/PLACEHOLDER" > /dev/null
zip -r "temp/${file}.zip" * -x ".*/*" -x "Releases/*" -x "temp/*" -x "buildModule.sh" -x "*.bat" -x "*.zip" -x "system/priv-app/ScreenCam/PLACEHOLDER" > /dev/null

echo
echo Signing zip...
echo
mkdir -p "Releases"
jarsigner -keystore "${SigningKey}" -storepass "${keyPass}" -sigfile CERT -tsa http://timestamp.comodoca.com/rfc3161 -digestalg SHA-1 -signedjar "Releases/${file}-Signed.zip" "temp/${file}.zip" "${SigningKeyAlias}" --key-pass "${aliasPass}"
rm "temp/${file}.zip"
