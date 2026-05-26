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
| | Virtual Machine | Docker |
|---|---|---|
| Isolation | Full hardware level | Process level (namespaces) |
| Includes kernel | Yes | No — shares host kernel |
| Size | GBs | MBs |
| Startup | Minutes | Seconds |
| Use case | Full OS isolation | Lightweight app isolation |

### Secrets vs Environment Variables:
| | Environment Variables | Docker Secrets |
|---|---|---|
| Storage | `.env` file | `secrets/` files |
| Visibility | Available to all container processes | Mounted as files, more secure |
| Use case | Configuration values | Sensitive credentials |
| Git safety | Must be in `.gitignore` | Must be in `.gitignore` |

In this project, credentials are stored in a `.env` file (excluded from git) and passed to containers via `env_file` in Docker Compose.

### Docker Network vs Host Network:
| | Docker Network | Host Network |
|---|---|---|
| Isolation | Containers have their own network namespace | Container shares host network directly |
| Security | Containers only communicate through defined network | No isolation |
| Subject compliance | Required ✅ | Forbidden ❌ |

A custom bridge network called `inception` is used. Containers communicate using their service names (e.g. `mariadb`, `wp-php`) as hostnames.

### Docker Volumes vs Bind Mounts:
| | Named Volumes | Bind Mounts |
|---|---|---|
| Data location | Managed by Docker at defined path | Any host path |
| Subject compliance | Required ✅ | Forbidden ❌ |
| Persistence | Survives container removal | Survives container removal |
| Data path | `/home/ael-azha/data/` | Any path |

Two named volumes are used: one for WordPress files and one for the MariaDB database, both stored at `/home/ael-azha/data/` on the host machine.

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
