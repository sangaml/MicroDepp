FROM ubuntu

RUN apt-get update && apt-get install nginx -y 

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
