## Introduction

This is a docker container for syncing your OneDrive data, based on the
[OneDrive Free Client](https://github.com/skilion/onedrive) and [OneDrive-Docker container by remyjette](https://github.com/remyjette/OneDrive-Docker).

It supports running the OneDrive service as a specific user and more flexible configuration options.


## Setting up the application

Unfortunately, due to the requirement of authenticating with the OneDrive
service via OAuth, the first run must be an *interactive* run.

#### Step 1

```shell
docker pull caphm/onedrive
```

#### Step 2

```shell
docker run -it
  -v /path/to/onedrive:/onedrive
  -v /path/to/config:/config
  caphm/onedrive
```

*Note:*

* Update `/path/to/onedrive` to your actual path where you would like to store your OneDrive files.
* Update `/path/to/config` to your actual path where the configuration files are stored.
* By default, the onedrive service will run under `UID=1000` and `GID=1000`. See below for instructions on how to change this.

#### Step 3

1. The container will provide you with an authentication URI. Copy it and visit it in your browser.

2. Authenticate with your Microsoft Account.

3. After you accept the application, your browser will redirect to a blank page with the response URI in the address bar.

4. Copy the URI to the prompt and hit `Enter`

#### Step 4

You can keep the docker container running in the foreground.

-- or --

You can hit `CTRL-C` to stop it and then restart the container.

## Configuration

All configuration options of the original OneDrive Free Client are available. Refer to [its configuration documentation](https://github.com/skilion/onedrive#configuration) for details. Configuration files should be put into the location mapped to `/config`.

Beware of setting `sync_dir` to anything else than `/onedrive` without mapping the location to an appropriate path on the host. You should not need to specify a different value for `sync_dir` anyway, just change the host path mapped to `/onedrive` if you want to store your files in a different location.

By default, the service inside the container runs under `UID=1000` and `GID=1000`. To sepcify a different UID or GID, pass them via the environment variables `ONEDRIVE_UID` and `ONEDRIVE_GID`:

```shell
docker run -it
  -v /path/to/onedrive:/onedrive
  -v /path/to/config:/config
  -e ONEDRIVE_UID=<desired UID>
  -e ONEDRIVE_GID=<desired GID>
  caphm/onedrive
```

**Make sure that the specified UID and/or GID have read and write permissions to the volumes mapped to `/onedrive` and `/config`**.
The container will not change ownership or modify permissions itself. All files created will be owned by the specified UID and GID.