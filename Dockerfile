FROM comfortel/ubase:latest
MAINTAINER GateSPb <i@gatespb.com>

# ------------------------------------------------------------------------------
# Install base
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install \
            enca \
            build-essential \
            g++ \
            curl \
            libssl-dev \
            apache2-utils \
            libxml2-dev \
            sshfs

# ------------------------------------------------------------------------------
# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get -y install \
            nodejs
    
# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone https://github.com/c9/core.git /cloud9 \
    && cd /cloud9 \
    && ./scripts/install-sdk.sh \
    && sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js \
    && mkdir /workspace

WORKDIR /cloud9

# Add supervisord conf
ADD conf/cloud9.conf /etc/supervisor/conf.d/

# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Add volumes
VOLUME ["/workspace","/var/log/supervisor"]

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 80/tcp 3000/tcp

# ------------------------------------------------------------------------------
# Default environments.
ENV LISTEN 0.0.0.0
ENV PORT 80
ENV USERNAME comfortel
ENV PASSWORD comfortel
ENV WORKSPACE /workspace

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

