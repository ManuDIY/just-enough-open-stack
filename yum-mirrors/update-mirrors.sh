#!/bin/bash

# BEGIN CONFIG OPTIONS
REPOROOT=/var/www/html/mirrors
# END CONFIG OPTIONS

# This script will create/update all the yum repos needed for installation

COMPONENTS=${@-"base extras updates epel docker-ce-stable ansible ius elasticsearch-5.x"}
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

for COMPONENT in $COMPONENTS; do
    case $COMPONENT in
	base)
	    REPOPATH=$REPOROOT/centos-7
	    ;;
	extras)
	    REPOPATH=$REPOROOT/centos-7
	    ;;
	updates)
	    REPOPATH=$REPOROOT/centos-7
	    ;;
	epel)
	    REPOPATH=$REPOROOT/centos-7
	    ;;
	docker-ce-stable)
	    REPOPATH=$REPOROOT
	    ;;
	ansible)
	    REPOPATH=$REPOROOT/centos-7
	    ;;
	ius)
	    REPOPATH=$REPOROOT/centos-7
	    ;;
	elasticsearch-5.x)
	    REPOPATH=$REPOROOT
	    ;;
    esac
    if [ ! -d $REPOPATH ]; then
	mkdir -p $REPOPATH || exit 1
    fi
    reposync -c $YUMCONFIG -d -p $REPOPATH -n --repoid=$COMPONENT || exit 2
    if [ -d $REPOPATH/$COMPONENT/repodata ]; then
	createrepo --update $REPOPATH/$COMPONENT || exit 3
    else
	createrepo $REPOPATH/$COMPONENT || exit 4
    fi
done

    
