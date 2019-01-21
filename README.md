# Wufgear project's Docker baseimage running on Alpine Linux 3.8

This Docker image [(robertcsmith/baseimage-alpine3.8-docker](https://github.com/robertcsmith/baseimage-alpine3.8-docker) is based on the minimal OS [Alpine Linux](https://alpinelinux.org/).

##### Alpine version 3.8.0 (Released Nov 30, 2017)
##### Latest baseimage version tag 1.1

----

## What is Alpine Linux?
Alpine Linux is a Linux distribution built around musl libc and BusyBox. The image is only 5 MB in size and has access to a package repository that is much more complete than other BusyBox based images. This makes Alpine Linux a great image base for utilities and even production applications. Read more about Alpine Linux here and you can see how their mantra fits in right at home with Docker images.

## What purpose does this base file serve?
This image adds necessary build tools and removes them for images needing a common set of build packages. 
All wufgear images with the OS being Alpine SHOULD be a decendant of this image. Usage is simple: 
  * This Dockerfile creates an image that ensures almost all packages necessary to properly build your service are installed ensuring easy access to said tools. Almost all images however have special build dependancies. Make no direct changes to this file, rather use inheritence to install additional packages and to build out your code. 
  * Tini is used to keep processes running and stopping correctly and handle signals so the other processes it spawned do not become orphaned or zombie process. 
  * You will need to RUN the command below that removes the packages it previously installed and performs cleanup. If you wish to keep your container (and layers small (and yes you do want this), ensure the last Dockerfile RUN line is "source base-pkg --uninstall" and be sure that if it is the only command used in the last RUN that it is first invoked with "set -ex &&"
  * Should you need to extend this image where removal of the command has been ran with the uninstall flag was previously ran execute this simple line of code at the TOP of your Dockerfile: "RUN set -ex && source base-pkg --install;" then remember to 'RUN set -ex; source base-pkg --uninstall;' at the end of the Dockerfile extending	from this where no other images build upon it (build another Dockerfile from it).

## Features
  * Understand first that packages the base-pkg-mgr adds in a parent Dockerfile (this one actually) which are meant to be uninstalled at the end of the entire build (the last Dockerfile that extends from this) while various other packages are installed with the intention to persist through all build images to the vary end
  * Although not recommended, you can alter the packages by modifying the contents of the environmental variable BASE_PKGS in either at the command line at run time or building an image for later use. The easiest route would probably be to use a Compose file and define the service there altering the BASE_PKGS en var.
  * The script itself as included is OPTIONAL however it automatically removes cache files, unnecessary garbage files and all packages found in \$BASE_PKGS and is executed in one line of code:
      - RUN set -x; source base-pkg --uninstall;
  * IMPORTANT!!!! Although not front and center, I am integrating a system user with a UID/GID of 1001 named "app" which I hope to create containers which can be ran by a different user or group without problems (Docker creates and runs containers as root:root). So when creating and extending a Dockerfile from this, before a service is created, manually add the primary service process' user/group UID/GID and attach it by adding the group/GID to app. 

## Architectures
This image when built suports only 64 bit Intel/AMD (x86_64/amd64) but may also work alongside other architectures - make sure you test this.

## Packages installed
* See below for a list of the dev packages which are temporarily installed by default as well as the persistant packages
  - autoconf2.13 binutils file fortify-headers git gnupg g++ libc-dev musl-dev make openssl-dev pcre-dev perl-dev zlib-dev

## Environment Variables:
  - BASE_PKGS="autoconf2.13 binutils file fortify-headers git gnupg g++ libc-dev musl-dev make openssl-dev pcre-dev perl-dev zlib-dev"
  - APP_USER_ID="1001"
  - APP_GROUP_ID="1001"
* All three of these Variables also reside in a global .env file. This Dockerfile exports the variables so they can be carried on to any child shell, Dockerfile extension and/or processes.

## BEFORE USE OF ANY SORT YOU MUST 'BUILD' THE IMAGE
* The image should be built so that it can faithfully reside in the repository with the correct tag before creating any service container that extends this image. Remember to use the correct tag when updating the LABEL elements and for any reference found in the Dockerfile.

## Creating an instance:
* There realy should never be a specific reason to create a container from this image unless you wish to play in a 'sandbox' shared by all images extended from this.

## Docker Compose:
* Unless stated otherwise, building of this image in Compose will generally create a container when required options are set. It should  be built outside Compose on the command line using BUILD and placed in the registry where the first child image will invoke and build it prior to it being built and/or possibly used to create a container.

## Source Repository

* [Github - robertcsmith/baseimage-alpine3.8-docker](https://github.com/robertcsmith/baseimage-alpine3.8-docker)
