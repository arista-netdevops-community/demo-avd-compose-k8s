FROM avdteam/base:centos-8
LABEL maintainer="Arista Ansible Team <ansible@arista.com>"

ADD ./entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
CMD [ "/bin/bash", "-c", "/root/entrypoint.sh" ]
