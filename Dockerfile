FROM alpine:3.8

LABEL namespace="me.robertcsmith.wufgear" \
	me.robertcsmith.wufgear.base.name="base" \
	me.robertcsmith.wufgear.base.release="1.1" \
	me.robertcsmith.wufgear.base.flavor="-alpine3.8" \
	me.robertcsmith.wufgear.base.version="-docker" \
	me.robertcsmith.wufgear.base.tag=":latest, :1.1" \
	me.robertcsmith.wufgear.base.image="me.robertcsmith.wufgear/base1.0-alpine3.8-docker:1.1" \
	me.robertcsmith.wufgear.base.vcs-url="https://github.com/robertcsmith/base1.1-alpine3.8-docker:latest" \
	me.robertcsmith.wufgear.base.maintainer="Robert C Smith <robertchristophersmith@gmail.com>" \
	me.robertcsmith.wufgear.base.usage="README.md" \
	me.robertcsmith.wufgear.base.description="This image adds necessary build tools and removes them for images needing a \
		common set of build packages. All wufgear images SHOULD be a decendant of this image. Usage is simple: \
			  - This Dockerfile creates an image that ensures almost all packages necessary to properly build \
				your service are installed ensuring easy access to said tools. Almost all images however have \
				special build dependancies. Make no direct changes to this file, rather use inheritence to install \
				additional packages and to build out your code. Note that I plan to add a process manager to keep \
				running processes running correctly and handle signals making sure all things run smmooth. You will \
				need to run the final command as outlined below if you wish to keep your container small (and yes you \
				do want this). \
			  - ITS EASY = Near the end of YOUR build Dockerfile RUN set -ex && source base-pkg --uninstall; \
				This command ensures the final built image (where no further decendants that may modify the process \
				will need access to them) this will be slimmed down aa well yet be fully operational. \
			  - Should you need to extend an image where removal of the command has been ran with the uninstall flag \
				was previously ran execute this simple line of code at the TOP of your Dockerfile: \
				  - RUN set -ex && source base-pkg --install; \
		!!!REMEMBER!!! to 'RUN set -x; source base-pkg --uninstall;' at the end of every Dockerfile extending \
		from this where you do not plan to extend it (build another Dockerfile from it)."

ENV BASE_PKGS="autoconf2.13 binutils file fortify-headers git gnupg g++ libc-dev musl-dev make openssl-dev pcre-dev \
		perl-dev zlib-dev" \
	APP_USER_ID="1001" \
	APP_GROUP_ID="1001"

# Consistently assign IDs to new groups (often the process we wish to run and
# check https://pkgs.alpinelinux.org/packages as a resource). Then add it to the "app" user,
# so that regardless of dependencies subsequenyly installed (and while keeping in mind the"app"
# user already belongs to the primary "root" and secondary "app" groups) it will have the correct
# privliges to run the process in the container regardless that it is a "root" user
RUN set -ex \
	# Before anything takes place we update and/or upgrade the index for our apk tool
	&& apk update && apk upgrade \
	# Create a system group (-S) with a GID of 1001 (-g) named "app"
	&& addgroup -S -g $APP_GROUP_ID app \
	# Create a system user (-S) with no password (-D) with no home directory (-H) and a UID of 1001 (-u)
	# and bind the pre-existing "root" group as its primary group (-G root) and name it "app"
	&& adduser -S -D -H -u $APP_USER_ID -G root app \
	# To the "app" user add the secondary group "app"
	&& addgroup app app;

# Copy the local script base-pkg-mgr.sh to /usr/local/bin/base-pkg-mgr while setting its ownership
COPY --chown=app:root files/base-pkg-mgr.sh /usr/local/bin/base-pkg-mgr

# complete assigning permissions
RUN set -ex && chmod 0755 /usr/local/bin/base-pkg-mgr; \
	# elevate the visibility of these local variables to be accessible to child processes and shells
	export BASE_PKGS=$BASE_PKGS && export APP_USER_ID=$APP_USER_ID && export APP_GROUP_ID=$APP_GROUP_ID; \
	# utilize the source command to execute the installation of \$BASE_PKGS via the base-pkg-mgr's shell and scope
	source /usr/local/bin/base-pkg-mgr --install; \
	# The following packages are meant to persist into the final image and all containers built from it as they are often
	# needed while inside a running container or to ensure an init runs and watches over processes
	apk add --no-cache bash chrony libgcc nano perl tar tzdata unzip vim wget xz zip zlib;

# YOUR CODE EXECUTES HERE

# At the end of your Dockerfile before CMD you should execute the following as shown
# RUN set -xe; source base-pkg-mgr "${BASE-PKGS}" --uninstall;

# CMD is typically the last instruction but may be overridden by the cli execution or in a child Dockerfile
# and it is ok to put here as a default
CMD ["/bin/bash"]
