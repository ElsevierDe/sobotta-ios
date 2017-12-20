#!/bin/bash

MAXAGE=$(( 1 * 24 * 3600 )) # 1 day.
NOW=`date +%s`
DEVICES="ipad iphone"
CUCUMBER_ARGS=""
# position arguments after <options>
CUCUMBER_POSARGS=""
TARGET="all"
TARGETFREE=1
TARGETFULL=1

function usage {
  echo "Usage: $0 <options>"
  echo " Options: "
  echo "   -d \"ipad iphone\" --- device to use, space separated."
  echo "   -a features/search.feature --- additional arguments passed to cucumber."
  echo "   -t <all/full/free> --- run either free or full target."
  exit 1
}

# parse command line arguments
while getopts "d:a:t:" opt ; do
  case $opt in
    d)
      DEVICES="$OPTARG"
      ;;
    a)
      CUCUMBER_ARGS="$OPTARG"
      ;;
    t)
      TARGET="$OPTARG"
      ;;
    \?)
      usage
      ;;
  esac
done

shift $(( OPTIND-1 ))
CUCUMBER_POSARGS="$@"

case $TARGET in
  all)
    TARGETFREE=1
    TARGETFULL=1
    ;;
  free)
    TARGETFREE=1
    TARGETFULL=0
    ;;
  full)
    TARGETFREE=0
    TARGETFULL=1
    ;;
  *)
    usage
esac 


function runtest {
  device=$1
  basename=$2

  echo
  echo "==========================================================="
  echo "Running tests on $device for $basename..."

  # first find the .app directory.
  dirname=`find  /Users/*/Library/Developer/Xcode/DerivedData/sobotta-*/Build/Products/Debug-* -maxdepth 1 -name $basename`
  if test -z "$dirname" ; then
    echo "Unable to find built .app matching $basename - have you built the project in xcode?"
    exit 1
  fi
  if test `echo "$dirname" | wc -l` -gt 1 ; then
    echo "Found more than one .app matching $basename."
    exit 1
  fi

  # make sure the project has been built in the last $MAXAGE seconds.
  modsecs=`stat -f %m "$dirname"`
  diffsecs=`expr $NOW - $modsecs`
  if test $diffsecs -gt $MAXAGE ; then
    echo "Project was last built $(( diffsecs / 3600 / 24 )) hours ago. (too old, go into xcode and rebuild it.)"
    exit 1
  fi

  # actually run the test
  echo CONNECT_TIMEOUT=20 APP_BUNDLE_PATH="$dirname" DEVICE=$device cucumber $CARGS
  CONNECT_TIMEOUT=20 APP_BUNDLE_PATH="$dirname" DEVICE=$device cucumber $CARGS
  ret=$?
  if test $ret -ne 0 ; then
    echo "Test Failure?! (device: $device / type: $basename)"
    exit 1
  fi
}



for d in $DEVICES ; do
  if test "$d" == "ipad" ; then
    devtag="~@iphone"
  elif test "$d" == "iphone" ; then
    devtag="~@ipad"
  else
    echo "Invalid device? $d" ; exit 1
  fi
  if test "$TARGETFULL" -eq 1 ; then
    CARGS="$CUCUMBER_ARGS -t ~@free -t $devtag $CUCUMBER_POSARGS"
    runtest $d sobotta-full-cal.app
  fi
  if test "$TARGETFREE" -eq 1 ; then
    CARGS="$CUCUMBER_ARGS -t ~@full -t $devtag $CUCUMBER_POSARGS"
    runtest $d sobotta-free-cal.app
  fi
done
#runtest ipad sobotta*cal

