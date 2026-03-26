# serversetupwiz

Collection of server setup scripts for Arch Linux and Ubuntu.

## Usage

### Zsh + Oh My Zsh

Installs zsh (if missing), sets it as default shell, installs Oh My Zsh with autosuggestions and syntax highlighting.

```bash
curl -fsSL https://raw.githubusercontent.com/sssemil/serversetupwiz/main/init_zsh.sh | bash
```

### Docker + UFW

Installs Docker and UFW, configures firewall rules, and patches UFW to work properly with Docker. **Must be run as root.**

```bash
curl -fsSL https://raw.githubusercontent.com/sssemil/serversetupwiz/main/setup_docker_ufw.sh | sudo bash
```

### Nginx + SSL

Installs Nginx, configures UFW, sets up a site with Let's Encrypt SSL via Certbot. **Must be run as root.** Pass your domain as an argument.

```bash
curl -fsSL https://raw.githubusercontent.com/sssemil/serversetupwiz/main/nginx_with_ssl.sh | bash -s -- yourdomain.com
```