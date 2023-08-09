# vmangos-docker

> A Docker setup for VMaNGOS

This is a simple Docker setup for [VMaNGOS][vmangos]. It is heavily inspired by
[tonymmm1/vmangos-docker][tonymmm1-vmangos-docker] but aims to be easier and
more straightforward to use.

## Table of contents

+ [Install](#install)
  + [Dependencies](#dependencies)
  + [Preface](#preface)
  + [Instructions](#instructions)
    + [Using VMaNGOS at a specific commit](#using-vmangos-at-a-specific-commit)
    + [Post-installation steps](#post-installation-steps)
+ [Usage](#usage)
  + [Starting and stopping VMaNGOS](#starting-and-stopping-vmangos)
  + [Updating](#updating)
  + [Creating a database backup](#creating-a-database-backup)
  + [Extracting client data](#extracting-client-data)
+ [Maintainer](#maintainer)
+ [Contribute](#contribute)
+ [License](#license)

## Install

### Dependencies

+ [Docker][docker] (including [Compose V2][docker-compose])
+ A POSIX-compliant shell as well as various core utilities (such as `cp` and
  `rm`) if you intend to use the provided scripts to install, update and manage
  VMaNGOS

### Preface

This assumed client version is `5875` (patch `1.12.1`); if you want to set up
VMaNGOS to use a different version, search the provided `00`-prefixed scripts
for occurrences of `client_version=5875` and modify them accordingly. You will
also have to adjust the `./src/data/5875:/opt/vmangos/bin/5875:ro` bind mount
for the `vmangos_mangos` service in `./docker-compose.yml` accordingly.

The user that is used inside the containers has UID `1000` and GID `1000` by
default. You can adjust this, if needed; e.g., to match your host UID/GID. This
requires searching the scripts for `user_id=1000` and `group_id=1000` and
modifying these values as well as adjusting the environment variables
`VMANGOS_USER_ID` and `VMANGOS_GROUP_ID` in `./docker-compose.yml`.

### Instructions

First, clone the repository, initialize the submodules and generate the config
files:

```sh
user@local:~$ git clone https://github.com/mserajnik/vmangos-docker.git
user@local:~$ cd vmangos-docker
user@local:vmangos-docker$ ./00-create-or-reset-config-files.sh
```

At this point, you have to adjust the two configuration files in `./config` as
well as `./docker-compose.yml` for your desired setup. The default setup will
only allow local connections (from the same machine). To make the server
public, it is required to change the `VMANGOS_REALM_IP` environment variable
for the `vmangos_database` service in `./docker-compose.yml`. Simply replace
`127.0.0.1` with the server's WAN IP (or LAN IP, if you don't want to make it
accessible over the Internet).

VMaNGOS also requires some data that gets extracted from the client to work
correctly. To generate that data automatically during the installation, copy
the contents of your World of Warcraft client directory into
`./src/client_data`. Extracting the required client data can take many hours
(depending on your hardware). Some notices/errors during the generation are
normal and nothing to worry about.

If you have acquired the extracted data previously, you can instead place it
directly into `./src/data`, in which case the installer will skip extracting
the data.

After that, simply execute the installer:

```sh
user@local:vmangos-docker$ ./00-install.sh
```

This will build and use the latest version of VMaNGOS.

#### Using VMaNGOS at a specific commit

Alternatively, if you want to use VMaNGOS at a specific commit, you can provide
the Git commit hash as an argument, e.g.:

```sh
user@local:vmangos-docker$ ./00-install.sh 8a7035261655236cef6b2bfea1be7f2ceb229c6d
```

Note that this will __not__ pin the installation to the specified commit;
unless you also provide the commit hash as an argument to the update script
when updating, it will check out and use the latest VMaNGOS commit. It is also
__not__ possible (or intended) to use this feature to perform a clean downgrade
due to the database migrations.

#### Post-installation steps

After the installer has finished, you should have a running installation and
can create your first account by attaching to the `vmangos_mangos` service:

```sh
user@local:vmangos-docker$ docker attach vmangos_mangos
```

After attaching, create the account and assign an account level:

```sh
account create <account name> <account password>
account set gmlevel <account name> <account level> # see https://github.com/vmangos/core/blob/79efe80ae39d94a5e52b71179583509b1df75899/src/shared/Common.h#L184-L191
```

When you are done, detach from the Docker container by pressing
<kbd>Ctrl</kbd>+<kbd>P</kbd> and <kbd>Ctrl</kbd>+<kbd>Q</kbd>.

## Usage

For your convenience, a number of shell scripts are provided to keep managing
your VMaNGOS installation simple, without requiring detailed knowledge about
how VMaNGOS or Docker work.

These scripts are all in the root directory of this repository and prefixed
with `00` (so they are grouped together when viewing the directory).

I recommend taking a look at them to understand how they work and, if needed,
modifying them to better suit your needs.

### Starting and stopping VMaNGOS

VMaNGOS can be started and stopped using the following scripts:

```sh
user@local:vmangos-docker$ ./00-start.sh
user@local:vmangos-docker$ ./00-stop.sh
```

### Updating

Updating can be done via the provided update script. This will update the
submodules, rebuild the Docker images and run database migrations:

```sh
user@local:vmangos-docker$ ./00-update.sh
```

Alternatively, you can also pass a Git commit hash if you want to use a
specific version of VMaNGOS (see [here](#using-vmangos-at-a-specific-commit)
for more information about this), e.g.:

```sh
user@local:vmangos-docker$ ./00-update.sh 8a7035261655236cef6b2bfea1be7f2ceb229c6d
```

[Creating a database backup](#creating-a-database-backup) before updating is
recommended.

It is also recommended to look at the [VMaNGOS commits][vmangos-commits] before
updating to ensure that no changes with the potential to break this setup have
been introduced since the last update. Things to look out for in particular are
changes to the directory structure, the database migration handling as well as
configuration changes. If you notice such a change that has not yet been
addressed in this repository, please [let me know][issues].

If the update script fails with the notice that there is a new world database
import, simply follow the instructions that are also printed in such a case.

At times, this repository might also get updated. Please do not blindly run
`git pull` without looking at the commits to see what (potentially breaking)
changes may have been introduced.

### Creating a database backup

The three important databases VMaNGOS uses, `mangos`, `characters` and
`realmd`, can be exported as SQL dumps with the following script:

```sh
user@local:vmangos-docker$ ./00-create-database-backup.sh
```

The dumped databases can, by default, be found in `./backup`. If you want to
change that path, adjust the `./backup:/backup` bind mount for the
`vmangos_database` service in `./docker-compose.yml` accordingly.

### Extracting client data

If at any point after the initial installation you need to re-extract the
client data, you can do so by running the following script:

```sh
user@local:vmangos-docker$ ./00-extract-client-data.sh
```

Note that this will also remove any existing data in `./src/data`, so make sure
to create a backup of that in case you want to save it.

## Maintainer

[Michael Serajnik][maintainer]

## Contribute

You are welcome to help out!

[Open an issue][issues] or [make a pull request][pull-requests].

## License

[AGPL-3.0-or-later](LICENSE) © Michael Serajnik

[docker]: https://docs.docker.com/get-docker/
[docker-compose]: https://docs.docker.com/compose/install/
[tonymmm1-vmangos-docker]: https://github.com/tonymmm1/vmangos-docker
[vmangos]: https://github.com/vmangos/core
[vmangos-commits]: https://github.com/vmangos/core/commits/development

[issues]: https://github.com/mserajnik/vmangos-docker/issues
[maintainer]: https://github.com/mserajnik
[pull-requests]: https://github.com/mserajnik/vmangos-docker/pulls
