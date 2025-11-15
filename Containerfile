FROM quay.io/fedora/fedora-minimal

RUN     dnf upgrade -y \
    &&  dnf install -y python3-pip python3-devel gcc libffi-devel openssl-devel \
        redhat-rpm-config krb5-devel git sudo make rsync sshpass gawk vim tree awk ansible tar \
    &&  dnf clean all

RUN     groupadd --gid 1000 ansible || true \
    &&  useradd --uid 1000 --gid 1000 -m -s /bin/bash ansible \
    &&  echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible \
    &&  chmod 0440 /etc/sudoers.d/ansible

WORKDIR /home/ansible/project

RUN     python3 -m pip install --no-cache-dir --upgrade pip \
    &&  python3 -m pip install --no-cache-dir --no-warn-script-location \
        wheel ansible ansible-navigator ansible-lint ansible-runner \
        "molecule[lint,podman,docker]" yamllint ansible-builder

RUN     ~/.local/bin/ansible-galaxy collection install community.general \
    &&  ~/.local/bin/ansible-galaxy collection install ansible.posix

CMD ["/bin/bash"]
