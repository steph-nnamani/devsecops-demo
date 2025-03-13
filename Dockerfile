# This multi-stage build approach is efficient, as it allows 
# you to separate the build environment from the final production 
# image if you decide to add additional stages later.

# Build stage
FROM node:23-alpine3.21 AS build
WORKDIR /app

# Do before installing dependencies to leverage Docker’s caching
COPY package*.json ./

# Install dependencies in a clean and consistent manner 
# based on the lock file. This is faster and more 
# reliable for production builds than npm install.
RUN npm ci

# Copy all remaining application files from your build 
# context into the container’s /app directory.
COPY . .

# Execute the build script defined in your package.json. 
# This typically compiles and bundles your application for production.
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

# Nginx’s default document root /usr/share/nginx/html.
# The /dist folder stores the output of the build process
# Equivalent to /target folder in Maven java build

# By default, Nginx runs as a daemon (background process)

# daemon off tells Nginx to run in the foreground instead
# Running Nginx in the foreground ensures proper container lifecycle management
# Makes it easier to view logs and debug issues
