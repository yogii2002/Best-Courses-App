# Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json ./

ARG NODE_ENV=development
RUN if [ "$NODE_ENV" = "production" ]; then npm ci --only=production; else npm install; fi

COPY . .

RUN npm run build

# Stage 2: Serve static files with nginx
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]