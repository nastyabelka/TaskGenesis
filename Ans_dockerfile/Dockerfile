FROM ubuntu:bionic-20200219

ARG ANSIBLE_VERSION="2.9.17"
ARG AWSCLI_VERSION="1.18.19"

LABEL maintainer="Anastasiia_Biloshytska"
LABEL ansible_version=${ANSIBLE_VERSION}
LABEL aws_cli_version=${AWSCLI_VERSION}

RUN mkdir ./a_roles \
    mkdir ./key_ssh
WORKDIR /data


ENV AWSCLI_VERSION=${AWSCLI_VERSION}
RUN apt-get update \
    && apt-get install -y ansible curl python3 python3-pip python3-boto unzip  \
    && pip3 install --upgrade awscli==${AWSCLI_VERSION} 

RUN echo 'alias arun="ansible run"' >> ~/.bashrc

CMD ["/bin/bash"]