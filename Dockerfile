FROM nginx:alpine

COPY build/web /usr/share/nginx/html

EXPOSE 8000

CMD ["nginx", "-g", "daemon off;"]
