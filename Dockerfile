# Use the official Node.js 22 image.
# See https://hub.docker.com/_/node for more information.
FROM node:22 AS base

# Create app directory
WORKDIR /usr/src/app


# Install dependencies into temp directory
# This will cache them and speed up future builds
FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json package.lock.json /temp/dev/
RUN cd /temp/dev && npm ci

# Install with --production (exclude devDependencies)
RUN mkdir -p /temp/prod
COPY package.json package.lock.json /temp/prod/
RUN cd /temp/prod && npm ci --production

# Copy node_modules from temp directory
# Then copy all (non-ignored) project files into the image
FROM base AS prerelease
COPY --from=install /temp/dev/node_modules node_modules
COPY . .

ENV NODE_ENV=production

RUN npx tsc --noEmit

# Copy production dependencies and source code into final image
FROM base AS release
COPY --from=install /temp/prod/node_modules node_modules
COPY --from=prerelease /usr/src/app/.env .
COPY --from=prerelease /usr/src/app/.env.production .
RUN mkdir -p /usr/src/app/src
COPY --from=prerelease /usr/src/app/src ./src
COPY --from=prerelease /usr/src/app/package.json .

# TODO:// should be downloaded not at ENTRYPOINT
ENTRYPOINT [ "npx", "tsx", "--env-file=.env --env-file=.env.production", "src/index.ts" ]