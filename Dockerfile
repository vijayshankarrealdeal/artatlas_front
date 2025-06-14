FROM nginx:alpine

COPY lib/deployments/web /usr/share/nginx/html

EXPOSE 8000

CMD ["nginx", "-g", "daemon off;"]
