#!/bin/bash
set -e;

if [[ "--add" == $1 || "--install" == $1 ]]; then
	apk update;
	apk upgrade;
	apk add --no-cache ${BASE_PKGS};
elif [[ "--delete" == $1 || "--remove" == $1 || "--uninstall" == $1 ]]; then
	apk del ${BASE_PKGS};
	rm -rf /var/cache/apk/* 2>/dev/null;
else
	echo "This script ADDs (installs) or DELETEs (uninstalls) the packages listed within the \
\$BASE_PKGS environmental variable which defaults to the following:\
	--binutils (including: file gcc g++ make libc-dev fortify-headers)\
as well as:\
	--autoconf \
	--build-base \
	--git \
	--gnupg \
	--musl-dev \
	--tar \
	--wget \
	--xz \
One argument of those listed below must be specified or --help will be assumed:\
    --install = installs the base packages for software build instead of needing \
        to memorize those which are most common (see above) - the base image will \
		call this function on its own, unless overridden or removed it in a parent \
		Dockerfile, therefore you should never need to run this command with this argument.\
	--delete, --remove, --uninstall = these are identical in function in that they \
		remove previously installed packages from the initial base Dockerfile noted above.\
	--help (or if an argument is not supplied) = displays this usage message.";
fi
