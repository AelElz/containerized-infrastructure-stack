# User Documentation

This document explains how to use the Inception stack once it has been built — starting
and stopping it, reaching the website, managing credentials, and checking that
everything is healthy. For build/setup details aimed at developers, see
[DEV_DOC.md](DEV_DOC.md).

## What services does the stack provide?

The project runs three containers, each providing one part of a self-hosted WordPress
site:

| Service | Container name | What it does |
|---|---|---|
| NGINX | `nginx` | The only entry point from outside. Serves the site over HTTPS (port 443) and forwards PHP requests to WordPress. |
| WordPress + PHP-FPM | `wp-php` | Runs the WordPress CMS itself (the site's pages, admin panel, plugins, content). |
| MariaDB | `mariadb` | Stores all WordPress data (posts, pages, users, settings) in a database. |

You only ever talk to NGINX directly (via your browser); WordPress and MariaDB are only
reachable from inside the private Docker network.

## Starting and stopping the project

All commands are run from the repository root, using the provided [Makefile](Makefile):

| Command | What it does |
|---|---|
| `make` (or `make all`) | Builds the images (if needed) and starts all three containers in the background. |
| `make down` | Stops and removes the containers, without touching your data. |
| `make status` | Shows whether the containers are currently running (`docker ps`). |
| `make logs` | Prints the logs of all containers — useful when something isn't working. |
| `make clean` | Stops the containers and removes unused Docker resources (images, networks, build cache). |
| `make fclean` | Full reset: also deletes all WordPress files and database data on disk. **Irreversible** — only use this if you want to start completely fresh. |
| `make re` | `fclean` followed by `all` — a full rebuild from scratch. |

For everyday use, `make` to start and `make down` to stop is all you need.

## Accessing the website and the administration panel

Once the containers are running (`make status` shows all three as `Up`), open a browser
and go to:

- **Website (front end):** `https://ael-azha.42.fr`
- **Administration panel (WordPress dashboard):** `https://ael-azha.42.fr/wp-admin`

Because the site uses a self-signed TLS certificate (generated at build time, not signed
by a public certificate authority), your browser will show a security warning the first
time you visit — this is expected. Accept/continue past the warning to reach the site.

> If the domain doesn't resolve, make sure your machine's `/etc/hosts` contains a line
> pointing it at the host running the containers, e.g. `127.0.0.1 ael-azha.42.fr` for a
> local setup — see [DEV_DOC.md](DEV_DOC.md) for details.

## Locating and managing credentials

All credentials are defined before the stack is built and live in two places, both at
the repository root:

- **`srcs/.env`** — non-sensitive configuration and usernames:
  - `WP_ADMIN_USER` / `WP_ADMIN_PASSWORD` — the WordPress administrator account, used to
    log in at `/wp-admin`.
  - `WP_USER` / `WP_USER_PASSWORD` — a second, regular (non-administrator) WordPress
    user account.
  - `MYSQL_USER` / `MYSQL_DATABASE` — the database user and database name.
- **`secrets/db_password.txt`** and **`secrets/db_root_password.txt`** — the actual
  database passwords (for `MYSQL_USER` and the MariaDB `root` account respectively).
  These are deliberately kept out of `.env` and passed to containers as Docker secrets
  instead, so they're never exposed as plain environment variables.

To change any credential, edit the relevant file and rebuild with `make re` — WordPress
and the database are only configured with these values the first time the containers are
created, so a fresh rebuild is required for changes to take effect.

## Checking that the services are running correctly

- `make status` (or `docker ps`) — lists the containers and their state; all three
  (`nginx`, `wp-php`, `mariadb`) should show as `Up`.
- `make logs` (or `docker compose -f srcs/docker-compose.yml logs -f <service>` for one
  service) — shows startup and runtime logs; look for errors here if a container keeps
  restarting.
- Visiting `https://ael-azha.42.fr` in a browser and seeing the WordPress site load (past
  the certificate warning) confirms NGINX, PHP-FPM, and the database are all working
  together correctly.
