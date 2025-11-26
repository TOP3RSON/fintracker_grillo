# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Dependências
COPY package*.json ./
RUN npm ci --legacy-peer-deps || npm install

# Código
COPY . .

# Build
RUN npm run build

# Stage 2: Nginx
FROM nginx:alpine

RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
