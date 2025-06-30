FROM node:20

ARG TZ
ENV TZ="$TZ"

# Install basic development tools and iptables/ipset
RUN apt update && apt install -y less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  curl \
  squid \
  openssl \
  locales \
  software-properties-common && \
  locale-gen en_US.UTF-8

# Create linuxbrew home directory and set permissions
RUN mkdir -p /home/linuxbrew && chown -R node:node /home/linuxbrew

# Set locale environment variables
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install AWS CLI v2 with architecture detection
RUN ARCH=$(dpkg --print-architecture) && \
  if [ "$ARCH" = "arm64" ]; then \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
  else \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
  fi && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2.zip aws/

# Ensure default node user has access to /usr/local/share
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ARG USERNAME=node

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history \
  && chown -R $USERNAME /commandhistory

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Create workspace and config directories and set permissions
ARG LOCAL_WORKSPACE_FOLDER
RUN mkdir -p $LOCAL_WORKSPACE_FOLDER /home/node/.claude && \
  chown -R node:node $LOCAL_WORKSPACE_FOLDER /home/node/.claude

WORKDIR $LOCAL_WORKSPACE_FOLDER

RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_0.18.2_${ARCH}.deb" && \
  rm "git-delta_0.18.2_${ARCH}.deb"

# Set up non-root user
USER node

# Install Homebrew as node user
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Set up Homebrew environment
ENV PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc && \
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc

# Install global packages
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin

# Set the default shell to zsh rather than sh
ENV SHELL=/bin/zsh

# Default powerline10k theme
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install Claude
RUN npm install -g @anthropic-ai/claude-code

# Install asdf via Homebrew
RUN /home/linuxbrew/.linuxbrew/bin/brew install asdf && \
  echo 'export PATH="/home/node/.asdf/shims:$PATH"' >> ~/.bashrc && \
  echo '. "/home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh"' >> ~/.bashrc && \
  echo 'export PATH="/home/node/.asdf/shims:$PATH"' >> ~/.zshrc && \
  echo '. "/home/linuxbrew/.linuxbrew/opt/asdf/libexec/asdf.sh"' >> ~/.zshrc

# Install terraform via asdf
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
  asdf plugin add terraform https://github.com/asdf-community/asdf-hashicorp.git && \
  asdf install terraform latest && \
  asdf set --home terraform latest && \
  asdf reshim

# Install go via asdf
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
  asdf plugin add golang https://github.com/asdf-community/asdf-golang.git && \
  asdf install golang latest && \
  asdf set --home golang latest && \
  asdf reshim

# Install flutter dependencies
USER root
RUN apt-get update && apt-get install -y \
  clang \
  cmake \
  ninja-build \
  pkg-config \
  libgtk-3-dev \
  liblzma-dev \
  libstdc++-12-dev

USER node

# Install flutter via asdf
# Note: Flutter requires specific setup for ARM64 architecture
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
  asdf plugin add flutter https://github.com/oae/asdf-flutter.git && \
  asdf install flutter latest && \
  asdf set --home flutter latest && \
  asdf reshim && \
  flutter config --no-analytics && \
  flutter doctor -v || true

# Copy and set up proxy scripts
COPY squid.conf /usr/local/bin/
COPY domain-whitelist.txt /usr/local/bin/
COPY start-proxy.sh /usr/local/bin/
COPY update-whitelist.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/start-proxy.sh /usr/local/bin/update-whitelist.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/start-proxy.sh" > /etc/sudoers.d/node-proxy && \
  echo "node ALL=(root) NOPASSWD: /usr/bin/tee -a /etc/squid/domain-whitelist.txt" >> /etc/sudoers.d/node-proxy && \
  echo "node ALL=(root) NOPASSWD: /usr/bin/mv /tmp/* /etc/squid/domain-whitelist.txt" >> /etc/sudoers.d/node-proxy && \
  echo "node ALL=(root) NOPASSWD: /usr/bin/cp /tmp/* /etc/squid/domain-whitelist.txt" >> /etc/sudoers.d/node-proxy && \
  echo "node ALL=(root) NOPASSWD: /usr/sbin/squid -k reconfigure" >> /etc/sudoers.d/node-proxy && \
  chmod 0440 /etc/sudoers.d/node-proxy

# Add proxy settings to shell profiles
RUN echo 'export http_proxy=http://localhost:3128' >> /etc/profile.d/proxy.sh && \
    echo 'export https_proxy=http://localhost:3128' >> /etc/profile.d/proxy.sh && \
    echo 'export HTTP_PROXY=http://localhost:3128' >> /etc/profile.d/proxy.sh && \
    echo 'export HTTPS_PROXY=http://localhost:3128' >> /etc/profile.d/proxy.sh && \
    echo 'export no_proxy=localhost,127.0.0.1,::1' >> /etc/profile.d/proxy.sh && \
    echo 'export NO_PROXY=localhost,127.0.0.1,::1' >> /etc/profile.d/proxy.sh && \
    chmod +x /etc/profile.d/proxy.sh && \
    # Also add to zsh profile
    echo 'export http_proxy=http://localhost:3128' >> /etc/zsh/zshenv && \
    echo 'export https_proxy=http://localhost:3128' >> /etc/zsh/zshenv && \
    echo 'export HTTP_PROXY=http://localhost:3128' >> /etc/zsh/zshenv && \
    echo 'export HTTPS_PROXY=http://localhost:3128' >> /etc/zsh/zshenv && \
    echo 'export no_proxy=localhost,127.0.0.1,::1' >> /etc/zsh/zshenv && \
    echo 'export NO_PROXY=localhost,127.0.0.1,::1' >> /etc/zsh/zshenv && \
    # Also add to bashrc for non-login shells
    echo 'export http_proxy=http://localhost:3128' >> /etc/bash.bashrc && \
    echo 'export https_proxy=http://localhost:3128' >> /etc/bash.bashrc && \
    echo 'export HTTP_PROXY=http://localhost:3128' >> /etc/bash.bashrc && \
    echo 'export HTTPS_PROXY=http://localhost:3128' >> /etc/bash.bashrc && \
    echo 'export no_proxy=localhost,127.0.0.1,::1' >> /etc/bash.bashrc && \
    echo 'export NO_PROXY=localhost,127.0.0.1,::1' >> /etc/bash.bashrc

# Add update-whitelist to PATH and create alias
RUN ln -s /usr/local/bin/update-whitelist.sh /usr/local/bin/update-whitelist && \
    echo 'alias whitelist="update-whitelist"' >> /etc/bash.bashrc && \
    echo 'alias whitelist="update-whitelist"' >> /etc/zsh/zshenv

USER node
