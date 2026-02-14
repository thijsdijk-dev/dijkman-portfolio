# ---- Build stage ----
FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN chmod -R a+x /app/node_modules/.bin
RUN npm run build

# ---- Run stage ----
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

# Optional: basic cache headers could be added later via nginx.conf
