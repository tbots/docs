FROM python:rc-stretch
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
CMD [ "python", "app.py" ]
