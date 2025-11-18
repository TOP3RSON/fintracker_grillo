# Multi-stage build for FinTracker application
# Stage 1: Build the application
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the application for production
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:stable-alpine

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Remove default Nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy the built application to Nginx's html directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 (standard HTTP port for Nginx)
EXPOSE 80

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init"]

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
