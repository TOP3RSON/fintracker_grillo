FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json bun.lockb* package-lock.json* ./

# Install dependencies
RUN if [ -f "bun.lockb" ]; then \
      echo "Installing with Bun..." && \
      curl -fsSL https://bun.sh/install | bash && \
      export PATH="/root/.bun/bin:$PATH" && \
      bun install --frozen-lockfile; \
    elif [ -f "package-lock.json" ]; then \
      echo "Installing with npm..." && \
      npm ci --legacy-peer-deps; \
    else \
      echo "Installing with npm (fallback)..." && \
      npm install; \
    fi

# Copy source code
COPY . .

# Build the application
RUN if [ -f "bun.lockb" ]; then \
      export PATH="/root/.bun/bin:$PATH" && \
      bun run build; \
    else \
      npm run build; \
    fi

# Production stage
FROM nginx:alpine

# Copy nginx configuration
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built application to nginx html directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]