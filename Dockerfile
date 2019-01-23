FROM debian:stretch as builder
WORKDIR /root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    libexpat1-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl "https://codeload.github.com/andrew-d/rough-auditing-tool-for-security/zip/master" -o rats.zip && unzip rats.zip
RUN cd rough-auditing-tool-for-security-master \
    && ./configure \
    && make \
    && make install

FROM debian:stretch
MAINTAINER tomasz@napierala.org
WORKDIR /root
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    cppcheck \
    libexpat1 \
    locales \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /usr/local/bin/rats /usr/local/bin/rats
COPY --from=builder /usr/local/share/rats-* /usr/local/share/

# cleanup
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8
