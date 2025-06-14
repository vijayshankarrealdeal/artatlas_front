FROM gcr.io/distroless/static-debian11
COPY build/web /usr/share/nginx/html
CMD ["static-web-server", "--port", "$PORT", "--root", "/usr/share/nginx/html"]
