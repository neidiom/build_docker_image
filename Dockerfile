FROM nginx:1.17
CMD ["/bin/sh", "-c", "nginx -g 'daemon off;'; nginx -s reload;"]
