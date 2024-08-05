#!/bin/bash

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Determine OS type
if [ -f /etc/os-release ]; then
  . /etc/os-release
  os=$ID
else
  echo "OS not supported"
  exit 1
fi

# Install Docker and UFW based on the OS
if [ "$os" == "ubuntu" ]; then
  apt-get update
  apt-get install -y docker.io ufw
elif [ "$os" == "arch" ]; then
  pacman -Syu --noconfirm
  pacman -S --noconfirm docker ufw
else
  echo "OS not supported"
  exit 1
fi

# Add user to docker group
usermod -aG docker $SUDO_USER

# Set UFW rules
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 2376/tcp
ufw allow 2377/tcp
ufw allow 7946/tcp
ufw allow 7946/udp
ufw allow 4789/udp
ufw --force enable

# Check if Docker rules already exist and if not, add them
check_docker_rules="grep -q '# BEGIN UFW AND DOCKER' /etc/ufw/after.rules"
if ! eval "$check_docker_rules"; then
  docker_ufw_rules=$(cat <<EOL
# BEGIN UFW AND DOCKER
*filter
:ufw-user-forward - [0:0]
:ufw-docker-logging-deny - [0:0]
:DOCKER-USER - [0:0]
-A DOCKER-USER -j ufw-user-forward

-A DOCKER-USER -j RETURN -s 10.0.0.0/8
-A DOCKER-USER -j RETURN -s 172.16.0.0/12
-A DOCKER-USER -j RETURN -s 192.168.0.0/16

-A DOCKER-USER -p udp -m udp --sport 53 --dport 1024:65535 -j RETURN

-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 192.168.0.0/16
-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 10.0.0.0/8
-A DOCKER-USER -j ufw-docker-logging-deny -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -d 172.16.0.0/12
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 192.168.0.0/16
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 10.0.0.0/8
-A DOCKER-USER -j ufw-docker-logging-deny -p udp -m udp --dport 0:32767 -d 172.16.0.0/12

-A DOCKER-USER -j RETURN

-A ufw-docker-logging-deny -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix "[UFW DOCKER BLOCK] "
-A ufw-docker-logging-deny -j DROP

COMMIT
# END UFW AND DOCKER
EOL
  )
  echo "$docker_ufw_rules" | tee -a /etc/ufw/after.rules
fi
