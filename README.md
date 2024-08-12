# Zenoh Router: unofficial version
This is zenohd with Dockerfile to build Image for lightweight Zenoh Router with REST plugin.

## issue: 

https://github.com/eclipse-zenoh/zenoh/issues/1292

## changes:

https://github.com/eclipse-zenoh/zenoh/compare/main...anhaabaete:zenoh:patch-1

## docker build/run
```bash
    docker build -t zenoh_custom_router .
    docker run -d --name zenoh_custom_router -p 7447:7447 -p 8000:8000 zenoh_custom_router
```