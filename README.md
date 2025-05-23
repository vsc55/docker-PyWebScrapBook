# docker-PyWebScrapBook

Docker for the remote server of the firefox extension webscrapbook. 
* Server Web (Pypi): https://pypi.org/project/webscrapbook/
* Server Web (GitHub): https://github.com/danny0838/PyWebScrapBook
* Extension Firefox: https://github.com/danny0838/webscrapbook
* Docker Hub: https://hub.docker.com/r/vsc55/webscrapbook

## Create Container:
```
docker create --name PyWebScrapBook -v /dokers/PyWebScrapBook_data:/data -p 8080:8080/tcp vsc55/webscrapbook:latest
docker container start PyWebScrapBook
```
or
```
docker run -v /dokers/PyWebScrapBook_data:/data -p 8080:8080/tcp vsc55/webscrapbook:latest
```

## Version PyWebScrapBook and Python:
* 2.6.0 to last version
  * python:3.13.3-alpine
* 2.5.1 to 2.5.3
  * python:3.13.1-alpine
* 1.1.0 to 2.5.0
  * python:3.10.1-alpine
* 0.15.0 to 1.0.0
  * python:3.7.7-alpine
* 0.8.0 to 0.14.4 
  * python:3.7.3-alpine

## Arch Support
* i386
* Amd64
* ARM64
* ARM/v6
* ARM/v7