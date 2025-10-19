# Stage 1: Build Stage
FROM node:18-alpine AS build

# Metadata
LABEL author="[Jacob Taraya]"
LABEL version="1.0"

# Build argument
ARG buildversion=1.0

# Environment variables
ENV PORT=3000
ENV BUILD_VERSION=$buildversion
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install all dependencies (including devDependencies for build)
RUN npm install --legacy-peer-deps

# Copy source code
COPY . .

# Build the React app
RUN npm run build

# Stage 2: Production Stage with Nginx
FROM nginx:alpine AS production

# Remove default nginx config
RUN rm -rf /usr/share/nginx/html/*

# Copy built files from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom nginx configuration (optional)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80 || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
