# Dockerfile

# Use an official NGINX runtime as a parent image
FROM nginx:latest

# Remove default NGINX configurations
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom NGINX configuration file
COPY nginx.conf /etc/nginx/conf.d/

COPY . /usr/share/nginx/html

# Expose port 80 to allow incoming traffic
EXPOSE 80
