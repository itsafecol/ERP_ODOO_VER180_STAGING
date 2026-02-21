FROM odoo:19.0

# change to the root user
USER root

RUN apt-get update 
RUN apt-get install -y pkg-config libxml2-dev libxmlsec1-dev libxmlsec1-openssl python3-pip python3-qrcode git
RUN apt-get install -y gcc
RUN apt-get install -y python3-dev
#RUN pip3 install dropbox
#RUN pip3 install xmlsec
#RUN pip3 install git+https://github.com/pysimplesoap/pysimplesoap.git@master
RUN apt install -y python3.12-venv
#RUN python3-pip-whl python3-setuptools-whl
#RUN python3-pip-whl python3-setuptools-whl python3.12-venv
COPY ./requirements.txt .
RUN python3 -m venv venv
RUN ./venv/bin/pip3 install --no-cache-dir -r requirements.txt
#ENTRYPOINT ["./venv/bin/python3", "main.py"]
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
        python3-crontab \
        python3-dropbox \
        #python3-pyncclient \
        #python-nextcloud-api-wrapper \
        python3-boto3 \
        python3-paramiko 
#RUN python3 -m pip install -r pyncclient 
RUN apt-get update && apt-get install -y \
    python3-pip 
    #python3-pyncclient
        

# change to the odoo user
USER odoo
