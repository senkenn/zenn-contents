FROM node:18

RUN apt-get update && apt-get install -y sudo

# Add non administrative user
ARG CONTAINER_USER
ENV PASSWORD=${CONTAINER_USER}
ENV UID=9999
RUN useradd -mu ${UID} -s /bin/bash -G sudo ${CONTAINER_USER} && \
  echo ${CONTAINER_USER}:$PASSWORD | chpasswd && \
  echo "${CONTAINER_USER}   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER vscode

COPY ./entrypoint.sh .
ENTRYPOINT [ "./entrypoint.sh" ]
