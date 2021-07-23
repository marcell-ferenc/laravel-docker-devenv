# Docker development environment

It is a docker development environment skeleton for a basic laravel application.

The docker container configurations and the main `docker-compose.yml` file are located in the `.docker` folder.
There is a `Makefile` in the project root that automates the setup of the environment.

**NOTE**: Replace every occurrence of `yourdomain` string with your project name in this repository (filenames, file contents).

Write the following line to your hosts file
```bash
127.0.0.1 yourdomain.test
```

### Use of the Makefile

- `make` or `make help`
    - Shows what commands are available
- `make init`
    - Do the initial docker setup (config, migration, asset generation and other basic steps could be added here)
- `make run`
    - Run the dev environment
- `make composer`
    - Install php dependencies
- `make down` or `make stop`
    - Shut down or stops the running containers and remove orphans
- `make destroy`
    - Do a big cleanup (Stop all containers, prune volumes, images, containers and remove vendor, node_modules folders)

After running `make init` you are ready to work on the project. With `make down` or `make stop` you can turn it off.
Later you only need `make run` in order to get it up and running. See `make help` for further commands.

**NOTE**: Depending on the host platform, may the `make down` command remove database volume data.