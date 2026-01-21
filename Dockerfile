# Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies first (for better caching)
# Copy from frontend directory (build context is project root)
COPY frontend/package*.json ./
RUN npm install --no-audit && \
    npm cache clean --force

# Copy source code from frontend directory
COPY frontend/ .

# Build the application
RUN npm run build && \
    rm -rf node_modules && \
    npm cache clean --force

# Production stage (static with Nginx)
FROM nginx:1.27-alpine AS runner

# Install wget for health check
RUN apk add --no-cache wget

# Copy built application to nginx html directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx configuration for SPA routing
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Validate nginx configuration
RUN nginx -t

# Expose port
EXPOSE 80

# Health check (using wget or fallback to test file existence)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/health || exit 1

# Start nginx with validation (required for Easypanel)
CMD ["sh", "-c", "nginx -t && nginx -g 'daemon off;'"]
