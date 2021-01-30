# BUILD STAGE #########################
FROM rakudo-zef:2020.12 AS build

RUN mkdir /app

WORKDIR /app

# Copy and install deps first to not trash the podman cache on every source
# change.

# Install build dependencies
RUN apk add --no-cache openssl-dev

COPY META6.json .
RUN zef install --deps-only .

COPY . .
RUN raku -c -I. service.raku


# Workaround for a recent podman bug, which ignores folders in .dockerignore
# https://github.com/containers/buildah/issues/1582
RUN rm -rf releases .git .gitignore

# FINAL STAGE #########################
FROM alpine:3.13.1

# Install runtime dependencies
RUN apk add --no-cache openssl-dev

COPY --from=build /app /app
COPY --from=build /usr/local /usr/local

WORKDIR /app

ENV PATH=$PATH:/usr/local/share/perl6/site/bin

ENV RAKUBREW_ORG_PORT="10000" \
    RAKUBREW_ORG_HOST="0.0.0.0" \
    RAKUBREW_ORG_RELEASES_DIR="/releases"

EXPOSE 10000
CMD raku -I. service.raku
