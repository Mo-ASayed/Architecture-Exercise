# Use Nginx to serve the static files
FROM nginx:alpine

# Set the working directory to Nginx web root
WORKDIR /usr/share/nginx/html

# Copy the static files to the container
COPY . .

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
