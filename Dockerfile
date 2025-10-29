# Use multi-stage builds
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock/pnpm-lock.yaml)
COPY package.json ./

# Install dependencies.  Install production dependencies first to leverage caching.
ARG NODE_ENV=production
RUN if [ "$NODE_ENV" = "production" ]; then npm ci --only=production; else npm install; fi

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# --- Production Stage ---
FROM nginx:alpine

# Copy the build output from the builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy nginx configuration (if you have one, otherwise use the default)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Set environment variables (if needed)
ENV NODE_ENV production

# Start nginx
CMD ["nginx", "-g", "daemon off;"]