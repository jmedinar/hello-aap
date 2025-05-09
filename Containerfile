# Use a specific Fedora version for better reproducibility, or latest if preferred
FROM fedora:39

RUN dnf install -y \
    python3-pip \
    python3-devel \
    gcc \
    libffi-devel \
    openssl-devel \
    redhat-rpm-config \
    krb5-devel \
    git \
    sudo \
    make \
    rsync \
    sshpass \
    gawk \
		vim \
		tree \
    && dnf upgrade -y \
    && dnf clean all

# Create a non-root user for Ansible development
# Using a common UID/GID like 1000 can help with volume mount permissions
RUN groupadd --gid 1000 ansible || true && \
    useradd --uid 1000 --gid 1000 -m -s /bin/bash ansible && \
    echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible && \
    chmod 0440 /etc/sudoers.d/ansible

# Switch to the non-root user
USER ansible
WORKDIR /home/ansible/project

# Opt 1: Create and activate a Python virtual environment for Ansible tools
RUN python3 -m venv /opt/ansible_venv && \
    /opt/ansible_venv/bin/pip install --no-cache-dir --upgrade pip && \
    /opt/ansible_venv/bin/pip install --no-cache-dir wheel && \
    /opt/ansible_venv/bin/pip install --no-cache-dir \
        ansible-core \
        ansible \
        ansible-lint \
        "molecule[podman,docker]" \
        yamllint

# Opt 2: Set Ansible Tools Globally
#RUN python3 -m pip install --no-cache-dir --upgrade pip && \
#    python3 -m pip install --no-cache-dir wheel && \
#    python3 -m pip install --no-cache-dir \
#				ansible-core \
#				ansible \
#				ansible-lint \
#				"molecule[podman,docker]" \
#				yamllint

# Add the venv to the PATH for all subsequent commands and when the container runs
ENV PATH="/opt/ansible_venv/bin:$PATH"

# Optional: You can pre-install some common collections if you always need them
# RUN ansible-galaxy collection install community.general community.docker ansible.posix

# Set a default command (e.g., open a bash shell)
CMD ["/bin/bash"]


