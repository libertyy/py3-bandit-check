
FROM python:3.8.12-alpine

RUN apk update && apk add bash git
RUN pip install bandit

COPY ./post.sh /post.sh
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
