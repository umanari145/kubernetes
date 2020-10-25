From python:3.7.5-slim
RUN pip install flask==1.1.1 redis==3.3.8
COPY ./server.py /server.py
ENTRYPOINT ["python", "-u", "server.py" ] 