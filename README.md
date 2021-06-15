# Icecast docker image

[![Drone (cloud)](https://img.shields.io/drone/build/jee-r/docker-icecast?&style=flat-square)](https://cloud.drone.io/jee-r/docker-icecast)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/j33r/icecast?style=flat-square)](https://microbadger.com/images/j33r/icecast)
[![MicroBadger Layers](https://img.shields.io/microbadger/layers/j33r/icecast?style=flat-square)](https://microbadger.com/images/j33r/icecast)
[![Docker Pulls](https://img.shields.io/docker/pulls/j33r/icecast?style=flat-square)](https://hub.docker.com/r/j33r/icecast)
[![DockerHub](https://shields.io/badge/Dockerhub-j33r/icecast?logo=docker&style=flat-square)](https://hub.docker.com/r/j33r/icecast)


A docker image for [Icecast](https://www.icecast.org) based on [Alpine Linux](https://alpinelinux.org) and **[without root process](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user)**

## What is Icecast :

From [icecast.org](https://www.icecast.org/):

>   Icecast is a streaming media (audio/video) server which currently supports Ogg (Vorbis and Theora), Opus, WebM and MP3 streams.
>   It can be used to create an Internet radio station or a privately running jukebox and many things in between. It is very versatile in that new formats can be added relatively easily and supports open standards for communication and interaction.
>   
>   Icecast is distributed under the GNU GPL, version 2.

## How use this image :

### With Docker

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
    j33r/icecast:latest
```

Note: `--user $(id -u):$(id -g)` should work out of the box on linux systems. If your docker host run on windows or if you want specify an other user id and group id just replace with the appropriates values.   

### With Docker Compose

```yaml
services:
  icecast:
    image: j33r/icecast:latest
    container_name: icecast
    restart: unless-stopped
    user: "1000:1000"
    volumes:
    #  - ./config:/config
      - /etc/localtime:/etc/localtime:ro
    environments:
        - HOME=/config
        - TZ=Europe/Paris
    ports:
      - 8000:8000
```

## Volumes

`/config`: If you mount this directory you must provide a `icecast.xml` configuration file in it

## Config

By default image is running icecast with this [default config](rootfs/config/icecast.xml). 

## Environment variables

To change the timezone of the container set the `TZ` environment variable. The full list of available options can be found on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

You can also set the `HOME` environment variable this is usefull to get in the right directory when you attach a shell in your docker container.

## Logs

By [default](rootfs/config/icecast.xml) access and error logs are binded to `STDOUT` and `STDERR` so you can easily show logs by running `docker logs icecast`

# License

This project is under the [GNU Generic Public License v3](LICENSE) to allow free use while ensuring it stays open.

