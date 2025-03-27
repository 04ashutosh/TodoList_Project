# Use an Nginx base image
FROM nginx:alpine

# Copy React build files to Nginx's serving directory
COPY build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
