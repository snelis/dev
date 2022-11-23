FROM python

WORKDIR /app/install
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

WORKDIR /app/src
COPY src .

CMD ["flask", "run", "--host=0.0.0.0", "--port=8000"]
