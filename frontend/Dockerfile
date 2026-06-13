FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy website files
COPY frontend/index.html /usr/share/nginx/html/
COPY frontend/courses.html /usr/share/nginx/html/
COPY frontend/services.html /usr/share/nginx/html/
COPY frontend/admin.html /usr/share/nginx/html/
COPY frontend/course.html /usr/share/nginx/html/
COPY frontend/styles.css /usr/share/nginx/html/
COPY frontend/assets/logo.png /usr/share/nginx/html/
COPY frontend/assets/cover.png /usr/share/nginx/html/

# Copy custom nginx config
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
