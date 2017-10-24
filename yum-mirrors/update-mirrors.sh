#!/bin/bash

# BEGIN CONFIG OPTIONS
YUMCONFIG=/home/oiab/mirrors.conf
REPOROOT=/var/www/html/mirrors
# END CONFIG OPTIONS

# This script will create/update all the yum repos needed for installation

COMPONENTS=${@-"base extras updates epel docker-ce ansible ius elasticsearch-5.x"}
  # ^^ This needs to be modified whenever any new components are added so they will go by default

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
	docker-ce)
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

    
