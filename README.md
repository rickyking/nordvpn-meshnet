# NordVPN Meshnet Docker Container

This repository builds a Docker container running the NordVPN client with Meshnet enabled. It interacts with the GitHub Container Registry (GHCR) to publish images automatically.

## Usage

### Prerequisites
- A NordVPN Account (and a Token).
- Docker.
- (For Synology) SSH access or Container Manager.

### Getting a Token
You can generate a token from your NordVPN dashboard or by using `nordvpn login --token` logic on another machine. Actually, NordVPN Tokens are generated on their website under "Manual Setup" or "Access Token".
**Recommendation**: Use a "AccessToken" generated from the NordVPN Dashboard (Services -> NordVPN -> Manual Setup -> Generate new token).

### Deploying on Synology NAS

1. **Prepare the NAS**:
   - Ensure you have **Container Manager** (or Docker) installed.
   - Enabling SSH is recommended for troubleshooting but you can use the Task Scheduler or Container Manager UI.
   - **Crucial**: The container needs access to `/dev/net/tun`.
     - On some Synology DSM versions, you might need to run a script at boot to create the TUN device if it doesn't exist:
       ```bash
       #!/bin/sh -e
       if [ ! -d /dev/net ]; then mkdir -p /dev/net; fi
       if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200; fi
       chmod 0666 /dev/net/tun
       ```

2. **Docker Compose**:
   Copy the `docker-compose.yml` file to your NAS.
   Updates the `image` field to `ghcr.io/<your-github-username>/nordvpn-meshnet:latest`.
   Set your `NORDVPN_TOKEN`.

   Run:
   ```bash
   docker-compose up -d
   ```
   Or use the **Project** feature in Synology Container Manager to upload the `docker-compose.yml`.

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NORDVPN_TOKEN` | Your NordVPN Access Token (Required). | |
| `NORDVPN_NICKNAME` | Name of this device on Meshnet. | |
| `NORDVPN_ALLOW_PEER_ROUTING` | Comma-separated list of peers to allow routing. | |
| `NORDVPN_ALLOW_PEER_LOCAL` | Allow local network access. | |
| `NORDVPN_HEALTHCHECK_URL` | URL to check for connectivity. | `www.google.com` |

### Building Locally

```bash
docker build -t nordvpn-meshnet .
```
