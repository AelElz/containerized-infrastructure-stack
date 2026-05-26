*This project has been created as part of the 42 curriculum by ael-azha.*

# Inception
## Description

Inception is a system administration project from the 42 curriculum.
The project can run either inside a Virtual Machine (recommended for 42 evaluation) or directly on a Linux host machine.

Required tools:
- Docker
- Docker Compose
- GNU Make
- Git
- Linux OS (Debian/Ubuntu recommended)

The infrastructure consists of three containers:
- **NGINX** — the only entry point, serving HTTPS on port 443 with TLSv1.2/TLSv1.3
- **WordPress + PHP-FPM** — the web application, communicating with NGINX via FastCGI
- **MariaDB** — the database storing all WordPress data

All services are isolated in their own containers, connected through a Docker network, and their data persists through named Docker volumes.

## Project Description

### Use of Docker
Each service runs in a dedicated container built from a custom Dockerfile based on Debian Bookworm. No pre-built images are used (except the base OS). Docker Compose orchestrates all containers, volumes, and the network.

### Virtual Machine vs Docker:
  # Virtual Machine:
    - Provides full hardware-level isolation
    - Includes its own operating system kernel
    - Usually consumes several gigabytes of storage
    - Startup time is relatively slow (often minutes)
    - Best suited for complete operating system isolation and virtualization

  # Docker:
    - Uses process-level isolation through Linux namespaces and cgroups
    - Shares the host machine kernel instead of including its own
    - Lightweight, usually only a few megabytes in size
    - Starts almost instantly (typically seconds)
    - Designed for lightweight application deployment and containerization

  # Main Difference:
    - A Virtual Machine emulates an entire operating system, while Docker containers only isolate applications and processes while sharing the host kernel.
      This makes Docker significantly lighter and faster than traditional virtual machines.
    - Docker containers share the host kernel and use Linux namespaces (PID, NET, MNT, UTS, IPC, USER) to isolate processes from each other.

### Secrets vs Environment Variables

  # Environment Variables:
    - Commonly stored inside a .env file
    - Accessible by processes running inside the container
    - Mainly used for configuration values such as ports, usernames, or application settings
    - Must be excluded from Git repositories using .gitignore

  # Docker Secrets
    - Stored separately inside dedicated secrets/ files
    - Mounted into containers as secure files instead of regular environment variables
    - Intended for sensitive information such as passwords, API keys, and database credentials
    - Must also be excluded from Git repositories for security reasons
    
  # Main Difference
    - Environment variables are simple and convenient for general configuration, while Docker Secrets provide a more secure method for handling sensitive credentials by limiting direct exposure inside containers.

In this project, credentials are stored in a `.env` file (excluded from git) and passed to containers via `env_file` in Docker Compose.

### Docker Network vs Host Network
  # Docker Network
    - Containers run inside their own isolated network namespace
    - Communication only happens through explicitly defined Docker networks
    - Provides better security and isolation between services
    - Required by the project subject
  # Host Network
    - Containers directly share the host machine network
    - No network isolation between the host and the container
    - Less secure because services are exposed directly
    - Forbidden by the project subject
  # Network Configuration in This Project
    - Services communicate internally using their container names as hostnames, such as:
        - mariadb
        - wp-php
        - nginx
This allows the containers to communicate securely without exposing internal services directly to the host machine.

### Docker Volumes vs Bind Mounts
  # Named Volumes
    - Managed directly by Docker
    - Stored in predefined Docker-managed locations
    - Required by the project subject
    - Data persists even after container removal
    - Used for safer and cleaner data management
  # Bind Mounts
    - Directly map any host machine directory into a container
    - Managed manually by the host system
    - Forbidden by the project subject
    - Data also persists after container removal
    - Provides less abstraction and isolation than Docker volumes
  # Volume Configuration in This Project
    Two named Docker volumes are used:
      - One volume for WordPress website files
      - One volume for the MariaDB database
  # Both volumes are stored inside:
    /home/ael-azha/data/
  This ensures persistent storage, meaning data remains available even if containers are stopped, removed, or rebuilt.

### Instructions

## Prerequisites
    - Docker and Docker Compose installed
    - A Virtual Machine running Linux (Debian/Ubuntu recommended)

## Installation

**1. Clone the repository:**
```bash
git clone git@github.com:AelElz/Inception-DevOps-.git
cd Inception
```

**2. Create the `.env` file at `srcs/.env`:**
```env
DOMAIN_NAME=ael-azha.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=user
MYSQL_PASSWORD=yourpassword
MYSQL_ROOT_PASSWORD=yourrootpassword
WP_ADMIN_USER=ael-azha
WP_ADMIN_PASSWORD=yourpassword
WP_ADMIN_EMAIL=ael-azha@student.42.fr
WP_USER=student
WP_USER_PASSWORD=yourpassword
WP_USER_EMAIL=student@student.42.fr
```

**3. Add the domain to `/etc/hosts`:**
```bash
echo "127.0.0.1 ael-azha.42.fr" | sudo tee -a /etc/hosts
```

**4. Build and start the project:**
```bash
make
```

**5. Open your browser at:**
https://ael-azha.42.fr

**6. Accept the self-signed certificate warning and your WordPress site will be running**


### Available Makefile Commands

| Command | Action |
|---|---|
| `make` | Build images and start all containers |
| `make down` | Stop all containers |
| `make clean` | Stop containers and prune unused Docker resources |
| `make fclean` | Full reset — removes all data, images, and volumes |
| `make re` | Full clean then rebuild from scratch |
| `make logs` | Show logs of all containers |
| `make status` | Show running containers |

## Resources

### Documentation
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [Linux namespaces — man page](https://man7.org/linux/man-pages/man7/namespaces.7.html)

### AI Usage
Claude (claude.ai) was used throughout this project for:
- Understanding Docker concepts (namespaces, cgroups, volumes, networks)
- Debugging container errors by analyzing logs
- Understanding configuration files (nginx, php-fpm, mariadb)
- Explaining the difference between concepts required by the subject (VMs vs Docker, secrets vs env vars, etc.)

All AI-generated content was reviewed, tested, and understood before being used in the project.
