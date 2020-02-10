
FROM php:5.6-cli
LABEL maintainer="Alex Miller <Alex.Miller@devinit.org>"

RUN apt-get update
RUN apt-get install -y wget

ADD build.sh .

CMD ["./build.sh"]
