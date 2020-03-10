# docker-PyWebScrapBook

Docker for the remote server of the firefox extension webscrapbook. 
* Server Web: https://github.com/danny0838/PyWebScrapBook
* Server Web: https://pypi.org/project/webscrapbook/
* Extension Firefox: https://github.com/danny0838/webscrapbook
* Docker Hub: https://hub.docker.com/r/vsc55/webscrapbook


### Create Container:
```
docker run -v /dokers/PyWebScrapBook_data:/data -p 8080:8080/tcp vsc55/webscrapbook:latest
```
or
```
docker create --name PyWebScrapBook -v /dokers/PyWebScrapBook_data:/data -p 8080:8080/tcp vsc55/webscrapbook:latest
docker container start PyWebScrapBook
```
