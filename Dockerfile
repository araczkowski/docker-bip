FROM java:7

MAINTAINER Andrzej Raczkowski <araczkowski@gmail.com>

# get rid of the message: "debconf: unable to initialize frontend: Dialog"
ENV DEBIAN_FRONTEND noninteractive

EXPOSE 1527	7001


# all installation files
COPY scripts /scripts

# ! to speed up the build process - only to tests the build process !!!
#COPY files /files
# ! to speed up the build process - only to tests the build process !!!

# start the installation
RUN /scripts/install_main.sh


# ENTRYPOINT
ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
