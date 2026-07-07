# Developer Documentation

This document explains how to set up, build, and manage the Inception stack as a
developer. For instructions on using the site once it's running, see
[USER_DOC.md](USER_DOC.md).

## Setting up the environment from scratch

### Prerequisites

- Docker Engine and Docker Compose (v2, the `docker compose` plugin)
- GNU Make
- Git
- A Linux host (a VM is recommended for 42 evaluation, but a native Linux install works
  the same way)
- `sudo` access, needed once to add an `/etc/hosts` entry and to create the data
  directory under `/home/<login>/`

### Configuration files

Two sets of files must exist before the first build — they hold configuration and
credentials and are not checked in with real values by default.

**1. `srcs/.env`** — environment variables read by `docker-compose.yml` and passed into
the containers:

```env
# Domain
DOMAIN_NAME=ael-azha.42.fr

# MariaDB
MYSQL_DATABASE=wordpress
MYSQL_USER=user

# WordPress
WP_ADMIN_USER=ael-azha        # must NOT contain admin/administrator in any form
WP_ADMIN_PASSWORD=<choose a password>
WP_ADMIN_EMAIL=ael-azha@student.42.fr
WP_USER=student
WP_USER_PASSWORD=<choose a password>
WP_USER_EMAIL=student@student.42.fr
```

**2. `secrets/db_password.txt`** and **`secrets/db_root_password.txt`** — plain text
files containing a single password each (no quotes, no trailing newline needed):

```bash
printf '%s' 'your-db-user-password'  > secrets/db_password.txt
printf '%s' 'your-db-root-password'  > secrets/db_root_password.txt
```

These are mounted into the `wordpress` and `mariadb` containers as Docker secrets
(`/run/secrets/db_password`, `/run/secrets/db_root_password`) rather than passed as
environment variables — see the README's "Secrets vs Environment Variables" section for
why.

### Domain resolution

The self-signed certificate and NGINX config are built for `DOMAIN_NAME` (default
`ael-azha.42.fr`). For that hostname to resolve to the machine running the containers,
add it to `/etc/hosts`:

```bash
echo "127.0.0.1 ael-azha.42.fr" | sudo tee -a /etc/hosts
```

## Building and launching the project

Everything is driven by the root [Makefile](Makefile), which wraps Docker Compose:

```bash
make
```

This does two things, in order:

1. **`makedirs`** — creates the host directories the volumes will bind-mount to:
   `/home/ael-azha/data/wordpress` and `/home/ael-azha/data/mariadb` (`DATA_DIR` in the
   Makefile).
2. **`docker compose -f srcs/docker-compose.yml up --build -d`** — builds the three
   Dockerfiles under `srcs/requirements/{nginx,wordpress,mariadb}/` and starts the
   containers in the background.

What each Dockerfile does, briefly:

- **`nginx`** — installs `nginx` + `openssl` on `debian:bookworm`, generates a
  self-signed TLS certificate for `DOMAIN_NAME` at build time, and serves the site on
  443, forwarding `.php` requests to `wp-php:9000` over FastCGI.
- **`wordpress`** — installs `php-fpm` + `wp-cli` dependencies. Its entrypoint,
  [`wp-setup.sh`](srcs/requirements/wordpress/tools/wp-setup.sh), waits for MariaDB to
  be reachable, downloads/configures WordPress via `wp-cli`, creates the admin and
  regular user accounts from `.env`, then hands off to `php-fpm` in the foreground.
- **`mariadb`** — installs `mariadb-server`. Its entrypoint,
  [`init-db.sh`](srcs/requirements/mariadb/tools/init-db.sh), creates the database and
  user from `.env`/secrets on first run, then `exec`s `mysqld` directly so the database
  process itself becomes PID 1 and can be stopped/restarted cleanly.

## Managing containers and volumes

Makefile shortcuts (all just wrap `docker compose`):

| Command | Underlying action |
|---|---|
| `make` | `docker compose up --build -d` (+ creates data dirs first) |
| `make down` | `docker compose down` |
| `make status` | `docker ps` |
| `make logs` | `docker compose logs` |
| `make clean` | `make down` + `docker system prune -f` |
| `make fclean` | `make clean` + wipes `/home/ael-azha/data/{wordpress,mariadb}` + `docker volume prune -f` + `docker image prune -af` |
| `make re` | `make fclean` + `make` |

Useful raw Docker commands when working directly instead of through the Makefile:

```bash
# Rebuild a single service after changing its Dockerfile/config
docker compose -f srcs/docker-compose.yml up --build -d wordpress

# Follow logs for one container
docker compose -f srcs/docker-compose.yml logs -f mariadb

# Get a shell inside a running container
docker exec -it wp-php bash

# Inspect a volume's real host path
docker volume inspect srcs_wordpress_db
```

## Where project data lives and how it persists

The two named volumes defined in `srcs/docker-compose.yml` (`wordpress_files`,
`wordpress_db`) are configured with `driver_opts: {type: none, o: bind, device: ...}`,
which makes them **bind mounts wrapped as named volumes**: Docker manages/lists them
like normal volumes, but the actual data physically lives at fixed, known paths on the
host:

- `/home/ael-azha/data/wordpress` — WordPress core files, themes, plugins, uploads
  (mounted at `/var/www/html` in both the `nginx` and `wordpress` containers).
- `/home/ael-azha/data/mariadb` — the MariaDB data directory (mounted at
  `/var/lib/mysql` in the `mariadb` container).

Because this data lives outside the containers' writable layers, it survives
`make down`, container recreation, and rebuilds (`make` / `make re` without `fclean`).
It is only deleted by `make fclean`, which explicitly `rm -rf`s both directories — use it
deliberately when you want a truly clean slate.
