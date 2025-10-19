# Stage 1: Build Stage
FROM node:18-alpine AS build

# Metadata
LABEL author="[Jacob Taraya]"
LABEL version="1.0"

# Build argument
ARG buildversion=1.0

# Environment variables
ENV PORT=5000
ENV BUILD_VERSION=$buildversion
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev

# Copy application source
COPY . .

# Stage 2: Production Stage  
FROM node:18-alpine AS production

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Copy node_modules from build stage
COPY --from=build /app/node_modules ./node_modules

# Copy application code
COPY . .

# Fix ownership for security
RUN chown -R node:node /app

# Switch to non-root user
USER node

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start application
CMD ["node", "server.js"]
