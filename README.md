# NordVPN Meshnet Docker Container

This repository builds a Docker container running the NordVPN client with Meshnet enabled. It interacts with the GitHub Container Registry (GHCR) to publish images automatically.

## Quick Start

1. Copy the environment template:
   ```bash
   cp .env.template .env
   ```

2. Edit `.env` and add your NordVPN token (see [Getting a Token](#getting-a-token))

3. Start the container:
   ```bash
   docker compose up -d
   ```

4. Check the logs:
   ```bash
   docker compose logs -f
   ```

## Prerequisites

- A NordVPN Account with an active subscription
- Docker and Docker Compose
- (For Synology) SSH access or Container Manager

## Getting a Token

Generate a NordVPN Access Token from your NordVPN dashboard:

1. Log in to [my.nordaccount.com](https://my.nordaccount.com)
2. Go to **Services** → **NordVPN**
3. Click **Manual Setup**
4. Under "Access Token", click **Generate new token**
5. Copy the token and paste it into your `.env` file

> ⚠️ **Security**: Keep your token secret! Never commit your `.env` file to git.

## Configuration

### Environment File Setup

Copy `.env.template` to `.env` and configure the following variables:

#### Required Settings

| Variable | Description | Example |
|----------|-------------|---------|
| `NORDVPN_TOKEN` | Your NordVPN Access Token | `abc123...` |

#### Device Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `PUID` | User ID for file permissions | `1026` |
| `PGID` | Group ID for file permissions | `100` |
| `TZ` | Timezone | `Etc/UTC` |
| `NORDVPN_NICKNAME` | Device name on Meshnet | *(none)* |

> 💡 **Tip**: Find your UID/GID by running `id <username>` on your host system.

#### Healthcheck Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `NORDVPN_HEALTHCHECK_INTERVAL` | Seconds between connectivity checks | `300` |
| `NORDVPN_HEALTHCHECK_URL` | URL to verify connectivity | `www.google.com` |

#### Meshnet Peer Permissions

Configure which peers can access this node. Use peer hostnames (e.g., `my-device.nord`) or email addresses, comma-separated for multiple peers.

**DENY permissions** (applied first):

| Variable | Description |
|----------|-------------|
| `NORDVPN_DENY_PEER_ROUTING` | Block peers from routing traffic through this node |
| `NORDVPN_DENY_PEER_LOCAL` | Block peers from accessing local network |
| `NORDVPN_DENY_PEER_FILESHARE` | Block peers from file sharing |
| `NORDVPN_DENY_PEER_REMOTE` | Block peers from remote access |

**ALLOW permissions** (applied after DENY, overwrites DENY):

| Variable | Description |
|----------|-------------|
| `NORDVPN_ALLOW_PEER_ROUTING` | Allow peers to route traffic through this node |
| `NORDVPN_ALLOW_PEER_LOCAL` | Allow peers to access local network (requires routing) |
| `NORDVPN_ALLOW_PEER_FILESHARE` | Allow peers to share files |
| `NORDVPN_ALLOW_PEER_REMOTE` | Allow peers remote access |

**Example**: Allow your MacBook to route traffic and access local network:
```env
NORDVPN_ALLOW_PEER_ROUTING=my-macbook.nord
NORDVPN_ALLOW_PEER_LOCAL=my-macbook.nord
```

## Deploying on Synology NAS

### 1. Prepare the NAS

Ensure you have **Container Manager** (or Docker) installed. SSH access is recommended for troubleshooting.

**Important**: The container needs access to `/dev/net/tun`. On some Synology DSM versions, you need to create it at boot:

1. **Control Panel** → **Task Scheduler**
2. **Create** → **Triggered Task** → **User-defined script**
3. **General** tab:
   - Task: `Enable TUN`
   - User: `root` (Important!)
   - Event: **Boot-up**
4. **Task Settings** tab → **User-defined script**:
   ```bash
   #!/bin/sh -e
   # Create the necessary directory
   if [ ! -d /dev/net ]; then mkdir -p /dev/net; fi
   
   # Create the TUN device node if it doesn't exist
   if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200; fi
   
   # Set permissions
   chmod 0666 /dev/net/tun
   
   # Load the tun module if not already loaded
   if ! lsmod | grep -q "^tun\s"; then
     insmod /lib/modules/tun.ko
   fi
   ```
5. Save and manually **Run** the task once to apply immediately.

### 2. Deploy with Docker Compose

1. Copy `docker-compose.yml` and `.env.template` to your NAS
2. Create your `.env` file:
   ```bash
   cp .env.template .env
   nano .env  # Edit and add your token
   ```
3. Start the container:
   ```bash
   docker compose up -d
   ```

Or use the **Project** feature in Synology Container Manager to upload the `docker-compose.yml`.

## Building Locally

```bash
docker build -t nordvpn-meshnet .
docker compose up -d
```

## Troubleshooting

### View container logs
```bash
docker compose logs -f
```

### Check Meshnet status
```bash
docker exec nordvpn-meshnet nordvpn meshnet peer list
```

### Check NordVPN account
```bash
docker exec nordvpn-meshnet nordvpn account
```

### Manually enable Meshnet
```bash
docker exec nordvpn-meshnet nordvpn set meshnet on
```

## Credits

This project is based on [MattsTechInfo/Meshnet](https://github.com/MattsTechInfo/Meshnet). Thanks to the original author for the foundational work on NordVPN Meshnet Docker integration.

## License

MIT
