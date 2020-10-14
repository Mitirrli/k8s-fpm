# k8s-fpm
This is the Dockerfile for K8S FPM.

# quickstart
```shell script
$ docker build -t fpm-k8s . //使用 Dockerfile 创建镜像

$ docker login --username=<username> <registry>

$ docker tag <imageId> <image>:<version>

$ docker push <image>:<version>
```