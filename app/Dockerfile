FROM python:alpine

RUN apk add curl bind-tools bash

WORKDIR /app/install
COPY requirements.txt requirements.txt
COPY wait-for-it.sh .
RUN pip install -r requirements.txt

WORKDIR /app/src
COPY src .
ENV PYTHONUNBUFFERED=TRUE

CMD [ "uvicorn", \
  "app:app", \
  "--host", "0.0.0.0", \
  "--port", "8000"]
