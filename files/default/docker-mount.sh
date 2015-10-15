#!/bin/sh

# stolen from here http://jpetazzo.github.io/2015/01/13/docker-mount-dynamic-volumes/

set -e
CONTAINER="$1"
HOSTPATH="$2"
CONTPATH="$3"

if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
  echo "Usage: $0 <containername> <hostpath> <mountpoint>"
  exit 1
fi

if docker-enter $CONTAINER sh -c "cut -d' ' -f2 /proc/mounts" | grep $CONTPATH >/dev/null; then
  echo "$CONTPATH seems to be already mounted."
  exit 0
fi

REALPATH=$(readlink --canonicalize $HOSTPATH)
#printf "REALPATH:%s\n" "$REALPATH"
FILESYS=$(df -P $REALPATH | tail -n 1 | awk '{print $6}')

while read DEV MOUNT JUNK
do [ "$MOUNT" = "$FILESYS" ] && break
done </proc/mounts
[ "$MOUNT" = "$FILESYS" ] # Sanity check!
REALDEV=$(readlink --canonicalize $DEV)
#printf "DEV:%s\n" "$DEV"
#printf "REALDEV:%s\n" "$REALDEV"

while read A B C SUBROOT MOUNT JUNK
do [ $MOUNT = $FILESYS ] && break
done < /proc/self/mountinfo
[ $MOUNT = $FILESYS ] # Moar sanity check!
#printf "MOUNT:%s\n" "$MOUNT"
#printf "SUBROOT:%s\n" "$SUBROOT"
#printf "FILESYS:%s\n" "$FILESYS"

SUBPATH=$(echo $REALPATH | sed s,^$FILESYS,,)
#printf "SUBPATH:%s\n" "$SUBPATH"
DEVDEC=$(printf "%d %d" $(stat --format "0x%t 0x%T" $REALDEV))
#printf "DEVDEC:%s\n" "$DEVDEC"

docker-enter $CONTAINER sh -c \
         "[ -b $REALDEV ] || mknod --mode 0600 $REALDEV b $DEVDEC"
if [ -L "$DEV" ]; then
  docker-enter $CONTAINER sh -c \
    "[ -L $DEV ] || (mkdir -p $(dirname $DEV) ; ln -s $REALDEV $DEV)"
fi
docker-enter $CONTAINER sh -c "[ ! -d /tmpmnt ] && mkdir /tmpmnt"
docker-enter $CONTAINER mount $DEV /tmpmnt
docker-enter $CONTAINER mkdir -p $CONTPATH
docker-enter $CONTAINER mount -o bind /tmpmnt/$SUBROOT/$SUBPATH $CONTPATH
docker-enter $CONTAINER umount /tmpmnt
docker-enter $CONTAINER rmdir /tmpmnt
