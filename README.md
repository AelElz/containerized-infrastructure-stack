*This project has been created as part of the 42 curriculum by ael-azha.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to
build a small, production-style web infrastructure entirely with Docker: every service
runs in its own container, built from a custom Dockerfile written from scratch (no
pre-built service images), and everything is orchestrated with Docker Compose behind
a single Makefile entry point.

The stack serves a WordPress site over HTTPS, backed by a MariaDB database, with NGINX
as the sole entry point to the outside world:

- **NGINX** — the only exposed port, serving HTTPS on 443 with TLSv1.2/TLSv1.3
- **WordPress + PHP-FPM** — the web application, talking to NGINX over FastCGI
- **MariaDB** — the database storing all WordPress data

<img width="1400" height="729" alt="1_MiiTlPl89vwpv_bvFUjacQ" src="https://github.com/user-attachments/assets/de2e4197-6a6e-44f0-9991-62399962bd62" />

All three containers are isolated from each other, communicate only through a private
Docker network, and persist their data on the host through bind-mounted volumes so that
data survives container recreation.

<img width="506" height="618" alt="Capture_dcran_2022-07-19__16 24 51" src="https://github.com/user-attachments/assets/85b0ab7a-d76f-490f-b39b-a26281ae1816" />

For day-to-day usage instructions, see [USER_DOC.md](USER_DOC.md).
For setup, build, and container/volume management details, see [DEV_DOC.md](DEV_DOC.md).

## Project Description

### Use of Docker and sources

Each service (`nginx`, `wordpress`, `mariadb`) lives under `srcs/requirements/<service>/`
with its own `Dockerfile`, built from the `debian:bookworm` base image — no ready-made
NGINX/WordPress/MariaDB images are pulled. `srcs/docker-compose.yml` is what actually
builds each of these Dockerfiles and wires the resulting containers together with a
shared network, named volumes, environment variables, and secrets. The root
[Makefile](Makefile) is the single command a user or evaluator runs (`make`) to prepare
the host data directories and trigger `docker compose up --build`.

### Virtual Machine vs Docker

| | Virtual Machine | Docker |
|---|---|---|
| Isolation | Full hardware-level virtualization | Process-level isolation (namespaces + cgroups) |
| Includes kernel | Yes, its own full kernel | No — shares the host kernel |
| Image/disk size | Gigabytes | Megabytes |
| Startup time | Minutes | Seconds |
| Resource overhead | High (emulates full hardware) | Low (native processes, isolated) |
| Use case | Full OS isolation, different kernels/OSes | Lightweight, reproducible app isolation |

We chose Docker (as required by the subject) because each service only needs process
and filesystem isolation, not a full separate kernel — containers start in seconds and
share the host's resources far more efficiently than a VM per service would.

### Secrets vs Environment Variables

| | Environment Variables (`.env`) | Docker Secrets (`secrets/`) |
|---|---|---|
| Storage | Plaintext file, loaded via `env_file:` | Plaintext file, mounted read-only at `/run/secrets/<name>` |
| Visibility | Readable by any process in the container, and via `docker inspect` | Only visible as a file inside the container, not in `docker inspect` |
| Best suited for | Non-sensitive configuration (domain, DB name, usernames) | Sensitive values (passwords) |
| Subject requirement | Used for configuration | Required for passwords |

In this project, non-sensitive configuration (`DOMAIN_NAME`, `MYSQL_DATABASE`,
`MYSQL_USER`, WordPress usernames/emails, etc.) lives in `srcs/.env` and is passed to
containers via `env_file`. The two database passwords are kept out of `.env` entirely
and passed as Docker secrets (`secrets/db_password.txt`, `secrets/db_root_password.txt`),
which the `mariadb` and `wordpress` containers read from `/run/secrets/` at startup
instead of receiving them as environment variables.

### Docker Network vs Host Network

| | Docker (bridge) Network | Host Network |
|---|---|---|
| Isolation | Containers get their own network namespace | Container shares the host's network stack directly |
| Inter-container communication | Via service name as hostname (Docker's internal DNS) | Via `localhost`, no isolation |
| Security | Only explicitly published ports are reachable from outside | Every port a container binds is exposed on the host |
| Subject compliance | Required | Forbidden |

A custom bridge network called `inception` connects all three containers. They resolve
each other by service name (e.g. WordPress reaches the database at `mariadb:3306`, NGINX
reaches PHP-FPM at `wp-php:9000`) instead of relying on the host's network stack.

### Docker Volumes vs Bind Mounts

| | Named Volumes (Docker-managed) | Bind Mounts (raw host path) |
|---|---|---|
| Location | Docker-chosen path under `/var/lib/docker/volumes/` | Any path you specify on the host |
| Managed by | Docker CLI (`docker volume ls/inspect`) | Not tracked by Docker as an entity |
| Subject requirement | A named volume must be used | — |
| Data location requirement | Must physically live under `/home/<login>/data` | — |

This project uses **named volumes configured as bind mounts** (`driver: local` with
`driver_opts: {type: none, o: bind, device: ...}`) — the best of both: they show up as
proper Docker volumes (`docker volume ls`), while the underlying data is guaranteed to
live at a known, inspectable path on the host: `/home/ael-azha/data/wordpress` (WordPress
files) and `/home/ael-azha/data/mariadb` (database files), exactly as the subject requires.

## Instructions

See [DEV_DOC.md](DEV_DOC.md) for full setup-from-scratch instructions (prerequisites,
`.env`/secrets configuration, build/launch, container and volume management) and
[USER_DOC.md](USER_DOC.md) for how to use the running site once it's up.

Quick start:

```bash
git clone git@github.com:AelElz/Inception-DevOps-.git
cd Inception
echo "127.0.0.1 ael-azha.42.fr" | sudo tee -a /etc/hosts
make
```

Then open `https://ael-azha.42.fr` in a browser and accept the self-signed certificate
warning.

## Resources

### Documentation
- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [Linux namespaces — man page](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [Docker Secrets documentation](https://docs.docker.com/engine/swarm/secrets/)

### AI Usage
Claude (claude.ai / Claude Code) was used throughout this project for:
- Explaining Docker concepts (namespaces, cgroups, volumes, bridge networks) and how
  they map onto the subject's requirements
- Debugging container startup and permission errors by analyzing logs and process state
- Explaining configuration file syntax (NGINX server blocks, PHP-FPM pool config,
  MariaDB `.cnf` options) that was largely adapted from the distro's own defaults
- Explaining the conceptual comparisons required by the subject (VMs vs Docker, secrets
  vs environment variables, Docker network vs host network, volumes vs bind mounts)
- Writing and structuring this project's documentation (`README.md`, `USER_DOC.md`,
  `DEV_DOC.md`)

All AI-assisted explanations and generated content were reviewed, tested against the
running containers, and understood before being used in the project.
