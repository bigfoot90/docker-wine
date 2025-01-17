FROM i386/debian:buster-slim

ARG WINEVERSION="5.0"
ARG WINEUID=999
ARG WINEGID=999

ENV WINEVERSION=$WINEVERSION
ENV WINEHOME="/home/wine"
ENV WINEPREFIX="$WINEHOME/.wine32"
ENV WINEARCH="win32"

LABEL org.opencontainers.image.title="Wine"
LABEL org.opencontainers.image.ref.name="il2horusteam/wine"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/il2horusteam/wine"
LABEL org.opencontainers.image.authors="Oleksandr Oblovatnyi <oblovatniy@gmail.com>"
LABEL org.opencontainers.image.description="Wine $WINEVERSION 32-bit"

RUN export DEBIAN_FRONTEND=noninteractive \
 && dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      telnet \
      cabextract \
      gnupg2 \
      wget \
 && groupadd -g $WINEGID wine \
 && useradd \
      --system \
      -u $WINEUID \
      -g $WINEGID \
      --shell /sbin/nologin \
      --create-home --home-dir $WINEHOME \
      wine \
 && mkdir -p $WINEPREFIX \
 && wget https://dl.winehq.org/wine-builds/winehq.key -O - | apt-key add - \
 && echo "deb https://dl.winehq.org/wine-builds/debian buster main" > /etc/apt/sources.list.d/winehq.list \
 && wget https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key -O - | apt-key add - \
 && echo "deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" > /etc/apt/sources.list.d/obs.list \
 && { \
	   echo "Package: *wine* *wine*:i386"; \
		echo "Pin: version $WINEVERSION~buster"; \
		echo "Pin-Priority: 1001"; \
  } > /etc/apt/preferences.d/winehq.pref \
 && apt-get update \
 && apt-get install -y --no-install-recommends winehq-stable \
 && wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks \
 && chmod +rx /usr/bin/winetricks \
 && wine wineboot --init \
 && winetricks d3dx9 corefonts \
 && apt purge --auto-remove -y \
 && apt autoremove --purge -y \
 && rm -rf /var/lib/apt/lists/* \
 && chown -R wine:wine $WINEHOME

USER wine