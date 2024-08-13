# Zenoh Router: unofficial build

Zenohd - docker image for lightweight Zrnoh Router with REST plugin.

# Issue/Bug

[10.08.2024] Latest release of zenoh: `zenoh:1.0.0-alpha.5`. **Running** `zenohd` **with any configuration file** results in **error**.

**Command**: `zenohd -c DEFAULT_CONFIG.json5`

**Error**:

```bash
INFO main ThreadId(01) zenohd: zenohd v1.0.0-alpha.5 built with rustc 1.75.0 (82e1608df 2023-12-21)
thread 'main' panicked at zenohd/src/main.rs:122:42:
called Result::unwrap() on an Err value: JSON error: invalid type: string "", expected a list of whatami variants ('router', 'peer', 'client') at commons/zenoh-config/src/lib.rs:748.
note: run with RUST_BACKTRACE=1 environment variable to display a backtrace
```

**Issue:** https://github.com/eclipse-zenoh/zenoh/issues/1292

## Implemented changes

**Suggested solution -> source:**

https://github.com/eclipse-zenoh/zenoh/compare/main...anhaabaete:zenoh:patch-1

**Made change -> zenoh/src/main.rs:126-129**

```rust
- Config::from_file(conf_file).
+ Config::from_file(conf_file).unwrap_or_else(|e| {
+    // if file load fail, wanning, and load defaul config
+    tracing::warn!("Warn: File {} not found! {}", conf_file, e.to_string());
+    Config::default()
```

# Configuration `CUSTOM_CONFIG.json5`
TODO

# Deployment

```bash
# clone repository
git clone https://github.com/Sobczaczek/zenoh_router_custom.git
```

## (a) Local deployment - Docker Image (Dockerfile) 

```bash
# build image
docker build -t zenoh_custom_router .

# run container
docker run -d --name zenoh_custom_router -p 7447:7447 -p 8000:8000 zenoh_custom_router
```

## (b) Full deployment - Docker Compose
```bash
# run docker compose
docker compose up --build
```

## Expected output
```bash
[+] Running 1/0
 ✔ Container zenoh_router_custom-zenoh-1  Created                                                                                                                                                0.1s 
Attaching to zenoh-1
zenoh-1  | 2024-08-13T08:31:36.896427Z  INFO main ThreadId(01) zenohd: zenohd v0.11.0-dev built with rustc 1.72.0 (5680fa18f 2023-08-23)
zenoh-1  | 2024-08-13T08:31:36.897906Z  INFO main ThreadId(01) zenohd: Initial conf: {"access_control":{"default_permission":"deny","enabled":false,"rules":null},"adminspace":{"enabled":true,"permissions":{"read":true,"write":false}},"aggregation":{"publishers":[],"subscribers":[]},"connect":{"endpoints":[],"exit_on_failure":{"client":true,"peer":false,"router":false},"retry":{"period_increase_factor":2.0,"period_init_ms":1000,"period_max_ms":4000},"timeout_ms":{"client":0,"peer":-1,"router":-1}},"downsampling":[],"id":"48f05ed3386df1cc4892161cdda60c7d","listen":{"endpoints":["tcp/[::]:7447"],"exit_on_failure":true,"retry":{"period_increase_factor":2.0,"period_init_ms":1000,"period_max_ms":4000},"timeout_ms":0},"metadata":{"location":"Poznan PCSS","name":"custom router"},"mode":"router","plugins":{"rest":{"http_port":8000}},"plugins_loading":{"enabled":true,"search_dirs":["/zenoh/target/release/"]},"queries_default_timeout":10000,"routing":{"peer":{"mode":"peer_to_peer"},"router":{"peers_failover_brokering":true}},"scouting":{"delay":200,"gossip":{"autoconnect":{"peer":"router|peer","router":""},"enabled":true,"multihop":false},"multicast":{"address":"224.0.0.224:7446","autoconnect":{"peer":"router|peer","router":""},"enabled":true,"interface":"auto","listen":true,"ttl":1},"timeout":3000},"timestamping":{"drop_future_timestamp":false,"enabled":{"client":false,"peer":false,"router":true}},"transport":{"auth":{"pubkey":{"key_size":null,"known_keys_file":null,"private_key_file":null,"private_key_pem":null,"public_key_file":null,"public_key_pem":null},"usrpwd":{"dictionary_file":null,"password":null,"user":null}},"link":{"protocols":null,"rx":{"buffer_size":65535,"max_message_size":1073741824},"tls":{"client_auth":false,"client_certificate":null,"client_private_key":null,"root_ca_certificate":null,"server_certificate":null,"server_name_verification":null,"server_private_key":null},"tx":{"batch_size":65535,"keep_alive":4,"lease":10000,"queue":{"backoff":100,"congestion_control":{"wait_before_drop":1000},"size":{"background":4,"control":1,"data":4,"data_high":2,"data_low":4,"interactive_high":1,"interactive_low":1,"real_time":1}},"sequence_number_resolution":"32bit","threads":3},"unixpipe":{"file_access_mask":null}},"multicast":{"compression":{"enabled":false},"join_interval":2500,"max_sessions":1000,"qos":{"enabled":false}},"shared_memory":{"enabled":false},"unicast":{"accept_pending":100,"accept_timeout":10000,"compression":{"enabled":false},"lowlatency":false,"max_links":1,"max_sessions":1000,"qos":{"enabled":true}}}}
zenoh-1  | 2024-08-13T08:31:36.898277Z  INFO main ThreadId(01) zenoh::net::runtime: Using ZID: 48f05ed3386df1cc4892161cdda60c7d
zenoh-1  | 2024-08-13T08:31:36.903032Z  INFO main ThreadId(01) zenoh::plugins::loader: Loading  plugin "rest"
zenoh-1  | 2024-08-13T08:31:36.904005Z  INFO main ThreadId(01) zenoh::plugins::loader: Starting  plugin "rest"
zenoh-1  | 2024-08-13T08:31:36.907644Z  INFO main ThreadId(01) zenoh::plugins::loader: Successfully started plugin rest from "/zenoh/target/release/libzenoh_plugin_rest.so"
zenoh-1  | 2024-08-13T08:31:36.907689Z  INFO main ThreadId(01) zenoh::plugins::loader: Finished loading plugins
zenoh-1  | 2024-08-13T08:31:36.908548Z  INFO main ThreadId(01) zenoh::net::runtime::orchestrator: Zenoh can be reached at: tcp/172.18.0.2:7447
zenoh-1  | 2024-08-13T08:31:36.908802Z  INFO main ThreadId(01) zenoh::net::runtime::orchestrator: zenohd listening scout messages on 224.0.0.224:7446
```

## Simple test
```bash
# check local routers in network
curl http://localhost:8000/@/router/local

# Expected Output:
[
{ "key": "@/router/48f05ed3386df1cc4892161cdda60c7d", "value": {"locators":["tcp/172.18.0.2:7447"],"metadata":{"location":"Poznan PCSS","name":"custom router"},"plugins":{"rest":{"name":"rest","path":"/zenoh/target/release/libzenoh_plugin_rest.so"}},"sessions":[],"version":"v0.11.0-dev built with rustc 1.72.0 (5680fa18f 2023-08-23)","zid":"48f05ed3386df1cc4892161cdda60c7d"}, "encoding": "application/json", "time": "None" }
]
```