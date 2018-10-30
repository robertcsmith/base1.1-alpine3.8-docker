FROM alpine:3.8

LABEL robertcsmith.base.namespace="robertcsmith/" \
    robertcsmith.base.name="base" \
    robertcsmith.base.release="1.1" \
    robertcsmith.base.flavor="-alpine3.8" \
    robertcsmith.base.version="-docker" \
    robertcsmith.base.tag=":1.1, :latest" \
    robertcsmith.base.image="robertcsmith/base1.1-alpine3.8-docker" \
    robertcsmith.base.vcs-url="https://github.com/robertcsmith/base1.1-alpine3.8-docker:latest" \
    robertcsmith.base.maintainer="Robert C Smith <robertchristophersmith@gmail.com>" \
    robertcsmith.base.usage="README.md" \
    robertcsmith.base.description="\
This image adds necessary build tools and removes them for images needing a common set of build packages. All wufgear images SHOULD be a decendant of this image. \
 - This Dockerfile creates a base image that ensures almost all packages necessary to properly build your service are installed ensuring easy access to said tools. Almost all images however have special build dependancies. Make no direct changes to this file, rather use inheritence to install additional packages and to build out your code. Note that I plan to add a process manager to keep running processes running correctly and handle signals making sure all things run smmooth. You will need to run the final command as outlined below if you wish to keep your container small (and yes you do want this). \
 - ITS EASY = Near the end of YOUR build Dockerfile 'RUN set -ex && source base-pkg-mgr --uninstall;' This command ensures the final built image (where no further decendants that may modify the process will need access to them) this will be slimmed down aa well yet be fully operational. \
 - Should you need to extend an image where removal of the command has been ran with the uninstall flag was previously ran execute this simple line of code at the TOP of your Dockerfile: \
   - 'RUN set -ex && source base-pkg-mgr --install;' \
!!!REMEMBER!!! to 'RUN set -x; source base-pkg-mgr --uninstall;' at the end of every Dockerfile extending from this where you do not plan to extend it (build another Dockerfile from it)."

ENV BASE_PKGS="binutils autoconf2.13 git gnupg musl-dev make openssl-dev pcre-dev perl-dev zlib-dev" \
    PERSISTANT_PKGS="bash chrony libgcc openssl pcre perl tar tzdata unzip vim wget xz zip zlib" \
    APP_USER_ID="1979" APP_GROUP_ID="1979"

# Consistently assign IDs to new groups (often the process we wish to run and
# check https://pkgs.alpinelinux.org/packages as a resource). Then add it to the "app" user,
# so that regardless of dependencies subsequenyly installed (and while keeping in mind the"app"
# user already belongs to the primary "root" and secondary "app" groups) it will have the correct
# privileges to run the process in the container regardless that it is a "root" user
RUN set -ex; \
    # Before anything takes place we update and/or upgrade the index for our apk tool
    apk update && apk upgrade; \
    # Create a system group (-S) with a GID of 1979 (-g) named "app"
    addgroup -S -g $APP_GROUP_ID app; \
    # Create a system user (-S) with no password (-D) with no home directory (-H) and a UID of 1979 (-u)
    # and bind the pre-existing "root" group as its primary group (-G root) and name it "app"
    adduser -S -D -H -u $APP_USER_ID -G root app; \
    # To the "app" user add the secondary group "app"
    addgroup app app;

# Copy the local script base-pkg-mgr.sh to /usr/local/bin/base-pkg-mgr while setting its ownership
COPY --chown=app:root files/base-pkg-mgr.sh /usr/local/bin/base-pkg-mgr

# complete assigning permissions
RUN set -ex && chmod 0755 /usr/local/bin/base-pkg-mgr; \
    # elevate the visibility of these local variables to be accessible to child processes and shells
    export BASE_PKGS=$BASE_PKGS APP_USER_ID=$APP_USER_ID APP_GROUP_ID=$APP_GROUP_ID; \
    # utilize the source command to execute the installation of \$BASE_PKGS via the base-pkg-mgr's shell and scope
    source /usr/local/bin/base-pkg-mgr --install; \
    # The following packages are meant to persist into the final image and all containers built from it as they are often
    # needed while inside a running container or to ensure an init runs and watches over processes
    apk add --no-cache $PERSISTANT_PKGS;

# YOUR CODE EXECUTES HERE

# At the end of your Dockerfile before CMD you should execute the following as shown
# RUN set -xe; source base-pkg-mgr --uninstall;

# CMD is typically the last instruction but may be overridden by the cli execution or in a child Dockerfile
# and it is ok to put here as a default
CMD ["bash"]
