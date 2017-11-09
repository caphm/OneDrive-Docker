FROM debian as gosu
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	fetchDeps=' \
		ca-certificates \
		curl \
		gnupg \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	curl -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	curl -L -o /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu nobody true; \
	\
	apt-get purge -y --auto-remove $fetchDeps

FROM ubuntu:16.04

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/gosu

ENV ONEDRIVE_UID=1000 ONEDRIVE_GID=1000

# Fetch dependencies, install DMD (D language) which OneDrive Free Client relies on,
# install the OneDrive Free Client, then remove some packages to slim down the image
# and create user inside the container
RUN chmod +x /usr/local/bin/gosu; \
 && apt-get update \
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
