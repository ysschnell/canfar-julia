# Pull from CANFAR's public external mirror instead of the internal network
FROM images.canfar.net/skaha/base:latest

USER root

# Install Julia system dependencies and download/unpack the true 1.10.4 tarball binary
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    && wget https://julialang.org \
    && tar -xvzf julia-1.10.4-linux-x86_64.tar.gz -C /usr/local --strip-components=1 \
    && rm julia-1.10.4-linux-x86_64.tar.gz \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Switch back to the default CANFAR user to install Julia packages securely
USER juser
WORKDIR /home/juser

# Pre-install Jupyter notebook engine interface (IJulia)
RUN julia -e 'using Pkg; Pkg.add("IJulia"); Pkg.precompile()'

# Pre-bake Octofitter and orbit models so they don't take 10 minutes to install in your sessions
RUN julia -e 'using Pkg; Pkg.add(["Octofitter", "PlanetOrbits", "Symbolics"]); Pkg.precompile()'
