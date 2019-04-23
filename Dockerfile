FROM ubuntu

RUN sudo apt-get update && sudo apt-get install nginx 

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
