FROM ubuntu:bionic-20200219

ARG TERRAFORM_VERSION="0.12.23"
ARG AWSCLI_VERSION="1.18.19"

LABEL maintainer="Anastasiia_Biloshytska"
LABEL terraform_version=${TERRAFORM_VERSION}
LABEL aws_cli_version=${AWSCLI_VERSION}

RUN mkdir ./ter_template \
    mkdir ./key_ssh
WORKDIR /data


ENV AWSCLI_VERSION=${AWSCLI_VERSION}
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION}

RUN apt update \
    && apt list --upgradable \
    && apt-get install -y curl python3 python3-pip python3-boto unzip  \
    && pip3 install --upgrade awscli==${AWSCLI_VERSION} \
    && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip '*.zip' -d /usr/local/bin \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* *.zip

RUN echo 'alias tin="terraform init" \
          alias tplan="terraform plan" \
          alias tapp="terraform apply"' >> ~/.bashrc 


CMD    ["/bin/bash"]