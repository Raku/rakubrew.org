FROM croservices/cro-http:0.8.2
RUN mkdir /app
COPY . /app
WORKDIR /app

# Workaround for a recent podman bug, which ignores folders in .dockerignore
# https://github.com/containers/buildah/issues/1582
RUN rm -rf releases .git .gitignore

RUN zef install --deps-only . && perl6 -c -Ilib service.p6
ENV RAKUBREW_ORG_PORT="10000"
ENV RAKUBREW_ORG_HOST="0.0.0.0"
ENV RAKUBREW_ORG_RELEASES_DIR="/releases"
EXPOSE 10000
CMD perl6 -Ilib service.p6
