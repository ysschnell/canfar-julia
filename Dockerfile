# Pull from CANFAR's public external mirror instead of the internal network
FROM images.canfar.net/skaha/base:latest

USER root

# Install Julia 1.10.4 LTS
RUN apt-get update \
 && apt-get install -y --no-install-recommends wget ca-certificates \
 && wget -q https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.4-linux-x86_64.tar.gz \
 && tar -xzf julia-1.10.4-linux-x86_64.tar.gz -C /usr/local --strip-components=1 \
 && rm julia-1.10.4-linux-x86_64.tar.gz \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Shared, pre-baked depot (read-only fallback) + per-user writable depot first
ENV JULIA_DEPOT_PATH="~/.julia:/opt/julia_depot"
# Make the IJulia kernelspec system-wide instead of landing in /root
ENV JUPYTER_DATA_DIR=/usr/local/share/jupyter

# Install packages into the shared depot (override the depot just for build)
RUN JULIA_DEPOT_PATH=/opt/julia_depot julia -e 'using Pkg; Pkg.add("IJulia"); Pkg.precompile()'

RUN JULIA_DEPOT_PATH=/opt/julia_depot julia -e 'using Pkg; Pkg.add(["Octofitter", "PlanetOrbits", "Symbolics"]); Pkg.precompile()'

# Let any runtime UID read (and execute) everything
RUN chmod -R a+rX /opt/julia_depot /usr/local/share/jupyter
