FROM python:3-slim-buster

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    ca-certificates \
    libusb-1.0-0 \
    make \
 && apt-get autoclean && apt-get clean && apt-get -y autoremove \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists

ADD fomu-toolchain-Linux.tar.gz /opt

ENV PATH=/opt/fomu-toolchain-Linux/bin:$PATH

ENV USER=fomu
RUN adduser --disabled-password ${USER}

RUN usermod -a -G plugdev ${USER}

COPY 99-fomu.rules /etc/udev/rules.d/

USER ${USER}
WORKDIR /home/${USER}
