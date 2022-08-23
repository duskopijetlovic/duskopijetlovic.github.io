#!/bin/sh
# 
# Very basic; for example, no checking for adding a duplicate.

/mnt/usbflashdrive/mydotfiles/mutt-common-files/muttldap.pl $1 | \
sed -n '2p' | \
awk '{print "alias","\""  $2,$3 "\"""\t" $1}' >> \
/mnt/usbflashdrive/mydotfiles/mutt-common-files/muttaliases
