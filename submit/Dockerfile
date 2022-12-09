#FROM localhost/controversy-base-01
#ENV PYTHONPATH "${PYTHONPATH}:/app"
#COPY . /app
#WORKDIR /app

FROM r-base:4.1.3
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libpq-dev python3.10 python3-pip python3-setuptools python3-dev curl libcurl4-openssl-dev libxml2-dev libssl-dev
RUN pip3 install --upgrade pip

ENV PYTHONPATH "${PYTHONPATH}:/app"
WORKDIR /app

#ADD requirements.txt .
#ADD requirements.r .
COPY . /app

# installing python libraries
RUN pip3 install -r requirements.txt

# installing r libraries
RUN Rscript requirements.R

#RUN ["alias", "python=python3"]
#RUN ln -s /usr/bin/python3 /usr/bin/python & \
#    ln -s /usr/bin/pip3 /usr/bin/pip
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN ["chmod", "+x", "/app/detect_controversy.sh"]
RUN ["chmod", "+x", "/app/fasttext"]
RUN ["chmod", "+x", "/app/calculate"]
CMD ["sh", "-c", "/app/detect_controversy.sh $QUERY_TERM"]

