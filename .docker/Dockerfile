FROM ubuntu:22.04
WORKDIR /provision
COPY ./ssh_key_rsa.pub /root/.ssh/authorized_keys
COPY ./ubuntu_setup.sh ./
RUN ./ubuntu_setup.sh
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
