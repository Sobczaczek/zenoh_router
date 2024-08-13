# Zenoh Router: unofficial version
This is zenohd with Dockerfile to build Image for lightweight Zenoh Router with REST plugin.

# Issue/Bug

Latest relese of zenoh:<version> returns error while trying to run with configuration file:

**zenohd -c DEFAULT_CONFIG.json5**

https://github.com/eclipse-zenoh/zenoh/issues/1292

## Implemented changes

### solution -> source
https://github.com/eclipse-zenoh/zenoh/compare/main...anhaabaete:zenoh:patch-1

### change -> zenoh/src/main.rs:126-129
```rust
- Config::from_file(conf_file).
+ Config::from_file(conf_file).unwrap_or_else(|e| {
+    // if file load fail, wanning, and load defaul config
+    tracing::warn!("Warn: File {} not found! {}", conf_file, e.to_string());
+    Config::default()
```

## docker build/run
```bash
docker build -t zenoh_custom_router .
docker run -d --name zenoh_custom_router -p 7447:7447 -p 8000:8000 zenoh_custom_router
```