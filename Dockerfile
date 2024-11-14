FROM haskell:9.10.1-bullseye AS build

RUN apt-get update && \
    apt-get install -y \
      libsasl2-dev \
      libldap2-dev \
      libssl-dev \
      openssl \
      libevent-dev \
      libargon2-dev \
      wiredtiger \
      libsystemd-dev \
      build-essential \
      pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/ldapply

RUN cabal update

COPY ./ldapply.cabal /opt/ldapply/ldapply.cabal

RUN cabal build --only-dependencies -j4

COPY . /opt/ldapply

RUN cabal install

FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y \
      libldap-2.4-2 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /root/.local/bin/ldapply /bin/ldapply

CMD ["/bin/ldapply"]


