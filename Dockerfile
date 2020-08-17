FROM alpine:3.12

ENV HTTP_PORT=80
ENV EXTERNAL_PORT=80
ENV PUID=1000
ENV PGID=1000
#ENV TRACKER_URL=https://trackerslist.com/best_aria2.txt
ENV ENABLE_UPDATE_TRACKER=true
ENV ENABLE_AUTO_RANDOM_ARIA=false
ENV ENABLE_AUTO_CLEAR_ARIANG=true
ENV TZ=Asia/Shanghai

VOLUME ["/data","/conf"]

EXPOSE 80 6881 6888

WORKDIR /app
ADD app /app
RUN chmod +x /app/*.sh
ADD conf /conf
RUN echo '*/30 * * * * /app/tracker.sh' > /etc/crontabs/root
CMD /app/run.sh
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 CMD /app/healthcheck.sh

RUN apk add --no-cache \
    aria2 \
    wget \
    apache2-utils \
    sudo \
    nginx \
    curl \
    tzdata \
    bash \
    bash-doc \
    bash-completion

RUN ARIAGN_VERSION=`curl --silent "https://api.github.com/repos/mayswind/AriaNg/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'` \
    && mkdir -p /run/nginx \
    && mkdir -p /usr/share/nginx/html \
    && rm -rf /usr/share/nginx/html/* \
    && wget -N --no-check-certificate https://github.com/mayswind/AriaNg/releases/download/${ARIAGN_VERSION}/AriaNg-${ARIAGN_VERSION}.zip \
    && unzip AriaNg-${ARIAGN_VERSION}.zip -d /usr/share/nginx/html \
    && rm -rf AriaNg-${ARIAGN_VERSION}.zip \
    && echo Set disable_coredump false >> /etc/sudo.conf

RUN apk del \
    wget
