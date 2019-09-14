# docker-webscrapbook

Docker for the remote server of the firefox extension webscrapbook. https://pypi.org/project/webscrapbook/


### Create Container:
```
docker run -v /dokers/webscrapbook_data:/data -p 8080:8080/tcp vsc55/webscrapbook:0.9.0
```
or
```
docker create --name webscrapbook -v /dokers/webscrapbook_data:/data -p 8080:8080/tcp vsc55/webscrapbook:0.9.0
docker container start webscrapbook
```
