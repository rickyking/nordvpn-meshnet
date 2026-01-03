FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

LABEL maintainer="Antigravity"

# Configure the NordVPN client version to install at build (optional override)
ARG NORDVPN_CLIENT_VERSION

# Avoid interactions during build process
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies, get the NordVPN Repo, install NordVPN client, cleanup
RUN echo "**** Install dependencies ****" && \
    apt-get update && \
    apt-get install -y curl && \
    echo "**** Install NordVPN ****" && \
    if [ -z "$NORDVPN_CLIENT_VERSION" ]; then \
        curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh | sh -s -- -n; \
    else \
        curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh | sh -s -- -n -v "${NORDVPN_CLIENT_VERSION}"; \
    fi && \
    echo "**** Cleanup ****" && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/cache/apt/archives/* \
        /var/lib/apt/lists/* \
        /var/tmp/* && \
    echo "**** Finished software setup ****"

# Copy all the files we need in the container
COPY /fs /

# Make sure NordVPN service is running before logging in and launching Meshnet
# s6-overlay will start services in /etc/services.d/ (i.e. nordvpnd)
ENV S6_CMD_WAIT_FOR_SERVICES=1

# Run the login, config, and watch scripts
CMD nordvpn_login && meshnet_config && meshnet_watch
