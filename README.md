# Build and run with docker

Build application

```
./jenkins-files/planetway/run_build.sh
```

Build and run docker container in local development

```
docker-compose build
docker-compose up
```

Or with make

```
make build
make up
```

# Secrets

Self-signed certificate was generated with openssl

```
openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt -days 3650 -passout pass:secret -subj "/CN=localhost"
```