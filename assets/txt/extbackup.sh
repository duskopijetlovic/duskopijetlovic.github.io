#!/bin/sh

# https://thornton2.com/unix/freebsd/geli-encrypted-usb-backup.html

# Exports snapshots to the external backup disk.
#
# Plug in the external backup disk, then be ready to type its GELI key 
# to attach it when prompted.
#
# Usage:
#
#     ./backup.sh
#                     Perform a backup.
#
#     ./backup.sh -b
#                     Perform a backup, then play a chime through the
#                     PC speaker when done.
#
# Snapshots are made automatically via zfstools.
# The transfer is via zxfer.
# See this script's end comments for preparation howto.

# ######################################################################

thishost="$( hostname -s )"
thispool="zroot"

######################### Don't let zfs-auto-snapshot snapshot backups
exclude="com.sun:auto-snapshot"
#########exclude="${exclude},com.sun:auto-snapshot:015m"
######################### Other zxfer exclusions
exclude="${exclude},special_small_blocks"       # feat. not in usb disk
exclude="${exclude},keylocation,keyformat"      # not encrypted zfs
exclude="${exclude},pbkdf2iters"                # not encrypted zfs
exclude="${exclude},objsetid"                   # zxfer bug workaround

# ######################################################################

# Processing the command line switch
playchime=0
while getopts 'b' c
do
        case $c in
        b)      playchime=1     ;;
        *)      :               ;;      # nop
        esac
done

# Making sure zxfer is installed and the external backup drive is plugged in
if ! which zxfer >/dev/null 2>&1
then printf "%s\n" "Please install zxfer." >&2; exit 1
fi

if [ ! -e "/dev/gpt/external" ]
then
        printf "%s\t" "[FAIL]"
        printf "%s\n" "External drive not inserted." >&2
        exit 1
fi

# Attaching the external backup drive
gelidetach=1
if [ -e "/dev/gpt/external.eli" ]
then
        printf "%s\t" "[Note]"
        printf "%s\n" "External drive already attached."
        gelidetach=0
else
        printf "%s\t" "[ OK ]"
        printf "%s\n" "Attaching external backup drive."
        geli attach "/dev/gpt/external"
fi
if [ ! -e "/dev/gpt/external.eli" ]
then
        printf "%s\t" "[FAIL]"
        printf "%s\n" "External backup drive not mounted." >&2
        exit 1
fi

# Importing the external pool
zpoolexport=1
if zfs list -H "external" >/dev/null 2>&1
then
        printf "%s\t" "[Note]"
        printf "%s\n" "External pool already imported."
        zpoolexport=0
else
        printf "%s\t" "[ OK ]"
        printf "%s\n" "Importing external pool."
        zpool import -N external 
fi
if zfs list -H "external/${thishost}" >/dev/null 2>&1
then
        printf "%s\t" "[ OK ]"
        printf "%s\n" "Mounting 'external/${thishost}'."
        mkdir -p "/external/${thishost}"
        zfs mount "external/${thishost}"
else
        printf "%s\t" "[FAIL]"
        printf "%s\n" "External (backup) directory is missing in backup pool." >&2
        if [ $zpoolexport -eq 1 ]
        then
                printf "%s\t" "[back]"
                printf "%s\n" "Exporting external pool." >&2
                zpool export external 
        fi
        if [ $gelidetach -eq 1 ]
        then
                printf "%s\t" "[back]"
                printf "%s\n" "Detaching external backup drive." >&2
                geli detach "/dev/gpt/external.eli"
        fi
        exit 1
fi

# Backup proper
printf "%s\t" "[ OK ]"
printf "%s\n" "Commencing backup."

if zxfer -dFkPv -I "${exclude}" -R "${thispool}" "external/${thishost}"
then
        printf "%s\t" "[ OK ]"
        printf "%s\n" "Backup completed successfully."
        sync; sync; sync
        if zfs unmount "external/${thishost}"
        then
                printf "%s\t" "[ OK ]"
                printf "%s\n" "Unmounted 'external/${thishost}' cleanly."
        else
                printf "%s\t" "[WARN]"
                printf "%s\n" "Did not unmount 'external/${thishost}' cleanly."
        fi
        rmdir "/external/${thishost}" >/dev/null 2>&1
        rmdir "/external" >/dev/null 2>&1
else
        printf "%s\t" "[FAIL]"
        printf "%s\n" "Backup encountered a problem."
        sync; sync; sync
fi

# Clean-up
#
# Exporting the external pool
if [ $zpoolexport -eq 1 ]
then
        printf "%s\t" "[ OK ]"
        printf "%s\n" "Exporting external pool."
        zpool export external 
else
        printf "%s\t" "[Note]"
        printf "%s\n" "Leaving external pool in place."
fi

# Detaching the external backup drive
if [ $gelidetach -eq 1 ]
then
        printf "%s\t" "[ OK ]"
        printf "%s\n" "Detaching external backup drive."
        geli detach "/dev/gpt/external.eli"
else
        printf "%s\t" "[Note]"
        printf "%s\n" "Leaving external backup drive attached."
fi

# Announcing the completion 
printf "%s\t" "[ OK ]"
printf "%s\n" "Done."

if [ "$playchime" -eq 1 ]
then
        # Jetsons doorbell chime
        echo "T208O3L4FAL8B>L4C." >/dev/speaker 2>/dev/null
fi

# ######################################################################
#
# Backup cheat sheet
#
# Preparation:
#
# pkg install zfstools zxfer
#
# Creation of snapshots to back up:
#
# zfs get com.sun:auto-snapshot # list auto-snapshot status
# #
# # exclude filesystems from snapshotting
# #
# zfs set com.sun:auto-snapshot=false zroot/tmp
# zfs set com.sun:auto-snapshot=false zroot/usr/ports
# zfs set com.sun:auto-snapshot=false zroot/usr/src
# zfs set com.sun:auto-snapshot=false zroot/var/audit
# zfs set com.sun:auto-snapshot=false zroot/var/crash
# zfs set com.sun:auto-snapshot=false zroot/var/tmp
# #
# # exclude filesystems from super-frequent snapshotting
# #
# zfs set com.sun:auto-snapshot:015m=false zroot/ROOT
# #
# # snapshot root filesystem and all children except excluded above
# #
# zfs set com.sun:auto-snapshot=true zroot
# #
# # Fire off automatic snapshotting via cron
# #
# crontab -e
# a
# SHELL=/bin/sh
# PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# # zfstools automatic snapshotting
# 15,30,45 * * * * /usr/local/sbin/zfs-auto-snapshot 015m  4
# 0        * * * * /usr/local/sbin/zfs-auto-snapshot 1hly 24
# 7        0 * * * /usr/local/sbin/zfs-auto-snapshot 2dly  7
# 14       0 * * 7 /usr/local/sbin/zfs-auto-snapshot 3wky  4
# 28       0 1 * * /usr/local/sbin/zfs-auto-snapshot 4mth 12
# .
# wq
#
# Backup disk creation:
#
# thishost="$( hostname -s )"
# thispool="zroot"
# backupdev="da0"               # see dmesg after plugging in backup drive
#
# gpart destroy -F ${backupdev} # probably da0, see dmesg
# gpart destroy -F ${backupdev} # should error if already destroyed
# gpart create -s gpt ${backupdev}
# gpart add -a 1m -l external -t freebsd-zfs "${backupdev}"
# gpart show -l ${backupdev}    # should list new backup, whole disk
# grep "geli init" /var/log/bsdinstall_log      # how was live eli was created
# geli init -e AES-XTS -l 256 -s 4096 "/dev/gpt/external"
# geli attach /dev/gpt/external
# geli status                   # verify
# zpool create external gpt/external.eli
# zfs create external/${thishost}
# zpool list                    # verify
# zfs list                      # verify
# zpool export external 
# geli detach gpt/external.eli
#
# Backup procedure
#
# # don't let zfs-auto-snapshot snapshot backups
# exclude="com.sun:auto-snapshot"
# # other exclusions
# exclude="${exclude},special_small_blocks"     # usb disk doesn't have feature
# exclude="${exclude},keylocation,keyformat"    # not encrypted zfs
# exclude="${exclude},pbkdf2iters"              # not encrypted zfs
# geli attach /dev/gpt/external
# zpool import external 
# zxfer -B -dFkPv -I ${exclude} -R ${thispool} external/${thishost}
# zpool scrub -w external 
# zpool export external 
# geli detach gpt/external.eli
#
