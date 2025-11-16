# Static site image built on nginx
FROM nginx:1.27-alpine

# Remove default nginx content before copying the static site.
RUN rm -rf /usr/share/nginx/html/*

# Copy the repository (filtered by .dockerignore) into the web root.
COPY . /usr/share/nginx/html

# Surface the favicon at the expected root path for browsers.
RUN cp /usr/share/nginx/html/public/favicon.ico /usr/share/nginx/html/favicon.ico

EXPOSE 80

CMD ["nginx","-g","daemon off;"]
