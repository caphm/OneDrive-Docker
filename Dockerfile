FROM ubuntu:16.04

ENV ONEDRIVE_UID=1000 ONEDRIVE_GID=1000

# Fetch dependencies, install DMD (D language) which OneDrive Free Client relies on,
# install the OneDrive Free Client, then remove some packages to slim down the image
# and create user inside the container
RUN apt-get update \
 && apt-get -y install libcurl4-openssl-dev libsqlite3-dev wget gcc unzip make git \
 && wget http://downloads.dlang.org/releases/2.x/2.075.1/dmd_2.075.1-0_amd64.deb -O dmd.deb && dpkg -i dmd.deb \
 && git clone https://github.com/skilion/onedrive \
 && cd onedrive && git checkout v1.0.1 && make && make install \
 && apt-get remove -y wget gcc unzip make git \
 && apt-get autoremove -y \
 && useradd -U -d /config -s /bin/false onedrive \
 && usermod -G users onedrive

VOLUME /config /onedrive

ADD ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/local/bin/onedrive", "-m", "--confdir=/config", "--syncdir=/onedrive"]
