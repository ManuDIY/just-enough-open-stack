#!/bin/bash

# BEGIN CONFIG OPTIONS
REPOROOT=/var/www/html/mirrors
# END CONFIG OPTIONS

# This script will create/update all the yum repos needed for installation

COMPONENTS=${@-"c7-base c7-extras c7-updates c7-epel c7-docker-ce-stable c7-ansible c7-ius elasticsearch-6.x c7-treasuredata c7-curator-3 f26-fedora f26-updates f26-docker-ce-stable"}
  # ^^ This needs to be modified whenever any new components are added so they will go by default

# Find path of this script
pushd `dirname $0` > /dev/null
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
popd > /dev/null

# Generate mirrors.conf file
YUMCONFIG=${SCRIPTPATH}/mirrors.conf
cat <<EOF >$YUMCONFIG
[main]
reposdir=${SCRIPTPATH}/mirrors.repos
gpgcheck=1
http_caching=none
EOF

# Clean up from previous runs so we sync correctly
echo ">>> Cleaning up yum caches"
yum -c $YUMCONFIG clean all

for COMPONENT in $COMPONENTS; do
    case $COMPONENT in
	c7-base)
	    REPOPATH=$REPOROOT/centos/7
	    ;;
	c7-extras)
	    REPOPATH=$REPOROOT/centos/7
	    ;;
	c7-updates)
	    REPOPATH=$REPOROOT/centos/7
	    ;;
	c7-epel)
	    REPOPATH=$REPOROOT/centos/7
	    ;;
	c7-docker-ce-stable)
	    REPOPATH=$REPOROOT/centos/7
	    ;;
	c7-ansible)
	    REPOPATH=$REPOROOT/centos/7
	    ;;
	c7-ius)
	    REPOPATH=$REPOROOT/centos/7
	    ;;
  c7-treasuredata)
      REPOPATH=$REPOROOT/centos/7
      ;;
  c7-curator-3)
	    REPOPATH=$REPOROOT/centos/7
	    ;;
  elasticsearch-6.x)
	    REPOPATH=$REPOROOT
	    ;;
  f26-fedora)
      REPOPATH=$REPOROOT/fedora/26
      ;;
  f26-updates)
      REPOPATH=$REPOROOT/fedora/26
      ;;
  f26-docker-ce-stable)
    	REPOPATH=$REPOROOT/fedora
    	;;
	*)
	    echo "Undefined component [$COMPONENT]!"
	    exit 1
            ;;
    esac
    if [ ! -d $REPOPATH ]; then
	mkdir -p $REPOPATH || exit 1
    fi
    echo ">>> Running reposync on $COMPONENT"
    reposync -c $YUMCONFIG -d -p $REPOPATH -n --repoid=$COMPONENT || exit 2
    if [ -d $REPOPATH/$COMPONENT/repodata ]; then
	echo ">>> Updating local repo metadata for $COMPONENT"
	createrepo --update $REPOPATH/$COMPONENT || exit 3
    else
	echo ">>> Creating local repo metadata for $COMPONENT"
	createrepo $REPOPATH/$COMPONENT || exit 4
    fi
done
