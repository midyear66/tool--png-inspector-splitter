## Build stage: install deps and build static site with Bun
FROM oven/bun:1 AS build
WORKDIR /app

# Copy only package files first for better layer caching
COPY package.json bun.lockb* ./
RUN bun install --no-save

# Copy the rest of the project
COPY . .

# Build to generate index.html and public/
RUN bun run build

## Runtime stage: serve with Nginx
FROM nginx:alpine AS runtime
WORKDIR /usr/share/nginx/html

# Copy built artifacts
COPY --from=build /app/index.html ./index.html
COPY --from=build /app/public ./public

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

