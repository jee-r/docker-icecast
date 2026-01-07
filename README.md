# Icecast docker image

[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/j33r/icecast?style=flat-square)](https://microbadger.com/images/j33r/icecast)
![GitHub Workflow Status (branch)](https://img.shields.io/github/actions/workflow/status/jee-r/docker-icecast/deploy.yaml?branch=main&style=flat-square)
[![Docker Pulls](https://img.shields.io/docker/pulls/j33r/icecast?style=flat-square)](https://hub.docker.com/r/j33r/icecast)
[![DockerHub](https://img.shields.io/badge/Dockerhub-j33r/icecast-%232496ED?logo=docker&style=flat-square)](https://hub.docker.com/r/j33r/icecast)
[![ghcr.io](https://img.shields.io/badge/ghrc%2Eio-jee%2D-r/icecast-%232496ED?logo=github&style=flat-square)](https://ghcr.io/jee-r/icecast)


A docker image for [Icecast](https://www.icecast.org) based on [Alpine Linux](https://alpinelinux.org)

**Multi-architecture support:** `linux/amd64`, `linux/arm64`, `linux/arm/v7`

**Available tags:**
- `latest` - Latest stable release
- `<major>`, `<major>.<minor>`, `<major>.<minor>.<patch>` - Icecast semantic versions (e.g., `2`, `2.5`, `2.5.0`)
- `dev` - Development branch
- `<commit-sha>` - Specific commit

The container can run **[without root process](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user)** (see `--user` flag in examples below).

## What is Icecast

From [icecast.org](https://www.icecast.org/):

>   Icecast is a streaming media (audio/video) server which currently supports Ogg (Vorbis and Theora), Opus, WebM and MP3 streams.
>   It can be used to create an Internet radio station or a privately running jukebox and many things in between. It is very versatile in that new formats can be added relatively easily and supports open standards for communication and interaction.
>   
>   Icecast is distributed under the GNU GPL, version 2.

## How to use this image

### With Docker / Podman

```bash
docker run \
    --detach \
    --interactive \
    --name icecast \
    --user $(id -u):$(id -g) \
    #--volume ./config:/config \
    --volume /etc/localtime:/etc/localtime:ro \
    --env TZ=Europe/Paris \
    --env HOME=/config \
    --publish 8000:8000 \
    ghcr.io/jee-r/icecast:latest
```

**Notes:**
- `--user $(id -u):$(id -g)` should work out of the box on Linux systems. If your host runs on Windows or if you want to specify another user/group ID, replace with the appropriate values.
- Replace `docker` with `podman` if using Podman. For better security, consider running [Podman in rootless mode](https://docs.podman.io/en/latest/markdown/podman.1.html#rootless-mode).   

### With Docker Compose

```yaml
services:
  icecast:
    image: ghcr.io/jee-r/icecast:latest
    build:
      context: .
      dockerfile: Dockerfile
    container_name: icecast
    restart: unless-stopped
    user: "1000:1000"
    volumes:
    #  - ./config:/config
      - /etc/localtime:/etc/localtime:ro
    environment:
        - HOME=/config
        - TZ=Europe/Paris
    ports:
      - 8000:8000
```

## Volumes

`/config`: If you mount this directory, you must provide an `icecast.xml` configuration file in it.

## Configuration

By default, the image runs Icecast with this [default config](rootfs/config/icecast.xml).

## Environment variables

- `TZ`: Timezone for the container (default: UTC). See the full list on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
- `HOME`: Useful to set the working directory when attaching a shell to the container.

## Logs

By [default](rootfs/config/icecast.xml), access and error logs are bound to `STDOUT` and `STDERR`, so you can view them with:

```bash
docker logs icecast
# or
podman logs icecast
```

# License

This project is under the [GNU Generic Public License v3](LICENSE) to allow free use while ensuring it stays open.

