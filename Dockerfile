FROM alpine:3.3

# change timezone to Asia/Shanghai
RUN apk add --no-cache tzdata && \
    cp  /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime && \
    echo "Asia/Shanghai" >  /etc/timezone && \
    apk del --no-cache tzdata

# add bash and libc6-compat
RUN apk add --no-cache bash libc6-compat && \
    ln -s /lib /lib64 && \
    sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

# install gosu
ENV GOSU_VERSION 1.7
RUN set -x \
    && apk add --no-cache --virtual .gosu-deps \
        dpkg \
        gnupg \
        openssl \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apk del .gosu-deps

# add rain user and group (addgroup -g 200 -S rain)
RUN sed -i -r 's/nofiles/rain/' /etc/group && \
    adduser -u 200 -D -S -G rain rain

ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH $PATH:$JAVA_HOME/bin

ENV JAVA_VERSION 8u77
ENV JAVA_ALPINE_VERSION 8.77.03-r0

RUN set -x \
	&& apk add --no-cache \
		openjdk8-jre="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]
