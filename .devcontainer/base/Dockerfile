FROM node:18

ARG CONTAINER_USER
RUN useradd -ms /bin/bash $CONTAINER_USER

COPY ./entrypoint.sh .
ENTRYPOINT [ "./entrypoint.sh" ]
CMD ["bash"]
