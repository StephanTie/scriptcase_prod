ARG IMAGE
ARG TAG
ARG PORT

FROM $IMAGE:$TAG as wkhtmltopdf

USER  root
WORKDIR /apppy

COPY app.py requirements.txt entrypoint.sh  ./

RUN pip install -r requirements.txt 
#RUN pip3 install flask flask_shell2http
# Add a new low-privileged user
#RUN useradd -ms /bin/bash static_analyzers-user
#CMD [ "python", "-m" , "flask", "run", "-p 4000"]
#CMD [ "/app/hello.py"]
EXPOSE $CONTAINER_WKHTMLTOPDF_INTERNAL_PORT
ENTRYPOINT ["./entrypoint.sh"]
