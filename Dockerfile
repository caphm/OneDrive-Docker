FROM debian as builder
WORKDIR /tmp
RUN apt-get update \
  && apt-get -y install libcurl4-openssl-dev libsqlite3-dev wget gcc unzip make git \
  && git clone https://github.com/ncopa/su-exec && cd /tmp/su-exec && make \
  && wget http://downloads.dlang.org/releases/2.x/2.075.1/dmd_2.075.1-0_amd64.deb -O dmd.deb && dpkg -i dmd.deb \
  && git clone https://github.com/skilion/onedrive && cd /tmp/onedrive && make

FROM debian

COPY --from=builder /tmp/su-exec/su-exec /tmp/onedrive/onedrive /usr/local/bin/
COPY --from=builder /tmp/onedrive/onedrive.service /usr/lib/systemd/user/

ENV ONEDRIVE_UID=1000 ONEDRIVE_GID=1000

VOLUME /config /onedrive

# Fetch dependencies, install DMD (D language) which OneDrive Free Client relies on,
# install the OneDrive Free Client, then remove some packages to slim down the image
# and create user inside the container
RUN apt-get update \
  && apt-get -y install libcurl4-openssl-dev libsqlite3-dev \
  && useradd -U -d /config -s /bin/false onedrive \
  && usermod -G users onedrive

ADD ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/local/bin/onedrive", "-m", "--confdir=/config", "--syncdir=/onedrive"]
