# FinTracker - Docker Setup

This guide explains how to containerize and run your FinTracker application using Docker.

## Prerequisites

Before running the application with Docker, make sure you have:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed (for Windows, Mac, or Linux)
- [Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop)

## Docker Configuration

This project includes:

- `Dockerfile` - Production-ready image with multi-stage build using Nginx
- `stack-finance.yml` - Docker stack configuration for deployment with Traefik

## Building the Image

To build the FinTracker Docker image:

```bash
# Build the production image with the fintracker tag
docker build -t fintracker:latest .
```

## Running in Development Mode

For a development environment with hot reloading, you can use:

```bash
# First build the development image
docker build -f Dockerfile.dev -t fintracker-dev:latest .

# Then run it with volume mounts for live updates
docker run -p 8080:8080 -v $(pwd):/app -v /app/node_modules fintracker-dev:latest
```

Note: On Windows, use `%cd%` instead of `$(pwd)` for volume mounting.

## Running in Production Mode

The application is configured to run as a Docker stack with Traefik reverse proxy:

```bash
# Deploy using the stack configuration
docker stack deploy -c stack-finance.yml fintracker
```

## Environment Variables

This React application uses environment variables that need to be available at build time. The following environment variables should be available when building the container:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`
- `VITE_SUPABASE_PROJECT_ID`

To build with environment variables, you can use Docker build args or build the image in an environment where these variables are already set:

```bash
# Example of building with environment variables
VITE_SUPABASE_URL="your_url" VITE_SUPABASE_PUBLISHABLE_KEY="your_key" VITE_SUPABASE_PROJECT_ID="your_project_id" docker build -t fintracker:latest .
```

Alternatively, you can create a runtime configuration file in your application that can be updated after deployment.

## Troubleshooting

1. **Port already in use**: Check if port 80 is already in use if running locally.

2. **Environment variables not loaded**: Environment variables with the VITE_ prefix must be available at build time and should be prefixed with VITE_ to be accessible in the React application.

3. **Build fails**: Check that all dependencies in package.json are valid and that there are no syntax errors in your code.

4. **Docker build context too large**: Consider adding files to `.dockerignore` to exclude unnecessary files from the build context.

## Docker Ignore

Your project already includes a `.dockerignore` file to optimize the build context.