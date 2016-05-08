FROM ubuntu:14.04

MAINTAINER  Paul Scott <pscott209@gmail.com>

ENV TERM linux
ENV ENV DEBIAN_FRONTEND noninteractive

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  apt-get install -y python python-dev python-pip && \
  apt-get install -y libtool autoconf bison swig && \
  apt-get install -y libglib2.0-dev portaudio19-dev python-dev mpg123 espeak && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir /mycroft && \
  TOP=/mycroft && \
  cd /mycroft && \

  git clone --recursive https://github.com/cmusphinx/pocketsphinx-python && \
  cd /mycroft/pocketsphinx-python/sphinxbase && \
  ./autogen.sh && \
  ./configure && \
  make && \
  cd /mycroft/pocketsphinx-python/pocketsphinx && \
  ./autogen.sh && \
  ./configure && \
  make && \
  cd ../../ && \
  cd /mycroft && \  
  
  # build and install pocketsphinx python bindings
  cd /mycroft/pocketsphinx-python && \
  python setup.py install && \
  cd ../ && \
  cd /mycroft && \

  # Checkout Mycroft
  git clone https://<username>:<password>@github.com/MycroftAI/mycroft.git /mycroft/ai/ && \
  cd /mycroft/ai && \
  easy_install pip==7.1.2 && \
  pip install -r requirements.txt --trusted-host pypi.mycroft.team && \
  cd .. && \
  cd /mycroft

  # install pygtk for desktop_launcher skill (will have to do this manually WIP)
  
# Set environment variables.
ENV HOME /mycroft

# Define working directory.
WORKDIR /mycroft
  
ENV PYTHONPATH $PYTHONPATH:/mycroft/ai/mycroft/client/speech/main.py
ENV PYTHONPATH $PYTHONPATH:/mycroft/ai/mycroft/client/messagebus/service/main.py
ENV PYTHONPATH $PYTHONPATH:/mycroft/ai/mycroft/client/skills/main.py

RUN \
  cd /mycroft/ai && \
  tmux new-session -d './start.sh service' && \
  tmux new-session -d './start.sh skills'  && \
  tmux new-session -d './start.sh voice'

EXPOSE 5000