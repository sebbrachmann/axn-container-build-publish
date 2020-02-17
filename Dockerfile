FROM docker:19.03.6

RUN apk update \
  && apk upgrade \
  && apk add --no-cache git curl jq

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
