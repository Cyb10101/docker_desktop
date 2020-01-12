# Docker Desktop

* Port 4000: NoMachine
* Recommend Desktop Size: 1280x768, 1440x900

Required:

```bash
--cap-add=SYS_PTRACE
```

Optional environment variables:

```bash
PASSWORD="Admin123!"
DISPLAY_WIDTH=1280
DISPLAY_HEIGHT=900
```

Example mounts:

```bash
./storage/downloads:/home/application/Downloads
./storage/.mozilla:/home/application/.mozilla
```
