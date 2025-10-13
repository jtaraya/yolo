# Use Node 18 Alpine (fixes dependency issues)
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files as root (before switching user)
COPY package*.json ./

# Install production dependencies as root
RUN npm ci --omit=dev

# Copy application source code
COPY . .

# Change ownership to node user (IMPORTANT!)
RUN chown -R node:node /app

# NOW switch to non-root user
USER node

# Expose the backend port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["npm", "start"]
