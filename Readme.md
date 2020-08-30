# Docker Desktop

* Port 4000: NoMachine
* Recommend Desktop Size: 1280x768, 1440x900

Required:

Synology: Container mit hoher Priorität ausführen = true

```bash
--cap-add=SYS_PTRACE
```

Optional environment variables:

```bash
PASSWORD="Admin123!"
DISPLAY_WIDTH=1280
DISPLAY_HEIGHT=900
NX_PORT=4001
```

Example mounts:

```bash
./storage/downloads:/home/application/Downloads
./storage/.mozilla:/home/application/.mozilla
```

## Troubleshooting

### No xserver running

```bash
xset q
# No display found

/etc/NX/nxserver --status
# Disabled service: nxnode
```
