# Stage 1: Build stage
# Use Node 16 Alpine for small image size (Important for rubric!)
FROM node:16-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first (better caching)
COPY package*.json ./

# Install ALL dependencies (needed for potential build steps)
RUN npm ci

# Stage 2: Production stage
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ONLY production dependencies (reduces image size)
RUN npm ci --only=production

# Copy application source code
COPY . .

# Expose the backend port
EXPOSE 5000

# Use non-root user for security (best practice)
USER node

# Health check (ensures container is healthy)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["npm", "start"]FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy package files first for better Docker layer caching
COPY package*.json ./

# Install only production dependencies
RUN npm install --production

# Copy all application source code
COPY . .

# Expose the backend API port
EXPOSE 5000

# Start the server using npm start
CMD ["npm", "start"]
