FROM gcr.io/distroless/static-debian11
COPY lib/deployments/web /usr/share/nginx/html
CMD ["/bin/sh", "-c", "static-web-server --port $PORT --root /usr/share/nginx/html"]
