FROM awalach/beego:1.9.4 AS builder

ADD . /go/src/github.com/rslota/openvpn-web-ui
WORKDIR /go/src/github.com/rslota/openvpn-web-ui

RUN go get
RUN bee pack -exr='^vendor|^data.db|^build|^README.md|^docs'

FROM debian:jessie

WORKDIR /opt
COPY --from=builder /go/src/github.com/rslota/openvpn-web-ui/openvpn-web-ui.tar.gz .

RUN mkdir -p /opt/openvpn-gui
RUN tar -xf openvpn-web-ui.tar.gz -C /opt/openvpn-gui

RUN apt-get update && apt-get install -y easy-rsa
RUN chmod 755 /usr/share/easy-rsa/*
RUN rm -f /opt/openvpn-gui/data.db
RUN ls /opt/openvpn-gui

ADD build/assets/start.sh /opt/start.sh
ADD build/assets/generate_ca_and_server_certs.sh /opt/scripts/generate_ca_and_server_certs.sh
ADD build/assets/vars.template /opt/scripts/
ADD build/assets/app.conf /opt/openvpn-gui/conf/app.conf

EXPOSE 8080
ENTRYPOINT [ "/opt/start.sh" ]
