
FROM php:5.6-cli
LABEL maintainer="Alex Miller <Alex.Miller@devinit.org>"

ADD build.sh .

CMD ["./build.sh"]
