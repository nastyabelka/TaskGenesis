FROM ubuntu:bionic-20200219

ARG TERRAFORM_VERSION="0.12.23"
ARG AWSCLI_VERSION="1.18.19"

LABEL maintainer="Anastasiia_Biloshytska"
LABEL terraform_version=${TERRAFORM_VERSION}
LABEL aws_cli_version=${AWSCLI_VERSION}

RUN mkdir ./ter_template \
    mkdir ./key_ssh
WORKDIR /data


ENV DEBIAN_FRONTEND=noninteractive
ENV AWSCLI_VERSION=${AWSCLI_VERSION}
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION}

RUN apt update \
    && apt list --upgradable \
    && apt install python3-pip \
    && pip3 install --upgrade awscli==${AWSCLI_VERSION} \
    && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && chmod 777 '*.zip' \
    && unzip '*.zip' -d /usr/local/bin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* *.zip

RUN echo 'tin="terraform init"' >> ~/.bashrc \
    echo 'tplan="terraform plan"' >> ~/.bashrc \
    echo 'tapp="terraform apply"' >> ~/.bashrc 

CMD    ["/bin/bash"]