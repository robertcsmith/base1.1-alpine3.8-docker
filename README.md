# Wufgear project's Base Docker image running on Alpine Linux 3.8

This Docker image [(robertchristophersmith/base1.1-alpine3.8-docker](https://hub.docker.com/r/robertchristophersmith/base1.1-alpine3.8-dockerb/) is based on the minimal [Alpine Linux](https://alpinelinux.org/).

##### Alpine Version 3.8.0 (Released Nov 30, 2017)
##### Base Version 1.1.0

----

## What is Alpine Linux?
Alpine Linux is a Linux distribution built around musl libc and BusyBox. The image is only 5 MB in size and has access to a package repository that is much more complete than other BusyBox based images. This makes Alpine Linux a great image base for utilities and even production applications. Read more about Alpine Linux here and you can see how their mantra fits in right at home with Docker images.

## What purpose does this base file serve?
This image adds necessary build tools and removes them for images needing a common set of build packages. 
All wufgear images SHOULD be a decendant of this image. Usage is simple: 
			  - This Dockerfile creates an image that ensures almost all packages necessary to properly build 
				your service are installed ensuring easy access to said tools. Almost all images however have 
				special build dependancies. Make no direct changes to this file, rather use inheritence to install 
				additional packages and to build out your code. Note that I plan to add a process manager to keep 
				running processes running correctly and handle signals making sure all things run smmooth. You will 
				need to run the final command as outlined below if you wish to keep your container small (and yes you 
				do want this).
			  - ITS EASY = Near the end of YOUR build Dockerfile RUN set -ex && source base-pkg --uninstall;
				This command ensures the final built image (where no further decendants that may modify the process
				will need access to them) this will be slimmed down aa well yet be fully operational.
			  - Should you need to extend an image where removal of the command has been ran with the uninstall flag
				was previously ran execute this simple line of code at the TOP of your Dockerfile:
				  - RUN set -ex && source base-pkg --install;
		!!!REMEMBER!!! to 'RUN set -x; source base-pkg --uninstall;' at the end of every Dockerfile extending
		from this where you do not plan to extend it (build another Dockerfile from it).

## Features

  * Understand first that packages the base-pkg-mgr adds in a parent Dockerfile (this one actually) which are
    meant to be uninstalled at the end of the build while various other packages are installed to persist through
    the build either into a container to be used or included to help child Dockerfiles
  * Although not recommended, you can alter the packages by modifying the Environmental Variable BASE_PKGS
    in either the command like to RUN or BUILD or through Docker Compose (which is the best option IMHO)
  * The cleanup script which is included is OPTIONAL and automatically removes cache files, unnecessary garbage 
    files and all packages found in \$BASE_PKGS all in one line of code:
        'RUN set -x; source base-pkg --uninstall;' 
    at the end of every Dockerfile extending	from this.
  * IMPORTANT!!!! Although not front and center, I am integrating a system UID/GID of 1001 named "app" which I hope containers
    can be run by without problems (Docker creates and runs containers as root:root). So when creating and extended
    Dockerfile from this, before the main process is added, you should manually add the primary system process' GID 
    and attach it to the always ready for action "app" system user.

## Architectures

* ```:amd64```, ```:latest``` - 64 bit Intel/AMD (x86_64/amd64)

## Volume structure
* See below for a list of the dev packages which are installed by defaul as well as the persistant ones
* `/usr/local/bin/base-pkg-mgr` is added to help manage core apk packages and remove them at the end of the build when they are no longer needed.

## Environment Variables:
BASE_PKGS="autoconf2.13 binutils file fortify-headers git gnupg g++ libc-dev musl-dev make openssl-dev pcre-dev	perl-dev zlib-dev"
APP_USER_ID="1001"
APP_GROUP_ID="1001"

All three of these Variables also reside in a global .env file and in this Dockerfile they are Exported for child shells and processes.

## Creating an instance:
There realy should never be a reason to create a container from this image unless you wish to play in a 'sandbox' shared by all images
extended through this.

## Docker Compose example:
To be verbose you could include a build of this image in Compose, but it is not a necessity at all.

## Source Repository

* [Github - robertcsmith/base1.1-alpine3.8-docker](https://github.com/robertcsmith/base1.1-alpine3.8-docker)
