
FROM python:3.6.10-alpine

RUN apk update && apk add bash git
RUN pip install bandit

COPY ./post.sh /post.sh
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
