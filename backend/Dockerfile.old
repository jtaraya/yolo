# Stage 1 Bulding stages 
FROM node:alpine AS build
LABEL author="Jacob Taraya"

ARG buildversion
# Environment variables
ENV port=5000
ENV build=$buildversion
ENV NODE_ENV=production

# Working path for the hosting app
WORKDIR /usr/src/app

# Install prod dependencies only to reduce image size omitting dev dependencies
RUN npm install --prod --omit=dev

# Copy entire source code from the host to the working directory of container
COPY . .

# stage 2 - Running stage
FROM alpine:3.16.7 AS prod
# Working path for container
WORKDIR /usr/src/app

# not caching the package index to keep image size small
RUN apk add --no-cache nodejs npm

# copy files from build stage to working dir of container
COPY --from=build /usr/src/app ./

EXPOSE $port

RUN echo "Build version: $build"
# Start the server
CMD ["node", "server.js"]