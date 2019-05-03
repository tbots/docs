FROM nginx:latest

RUN  apt update --yes
RUN  apt install --yes procps

EXPOSE "8080:80"
CMD ["nginx", "-g", "daemon off;" ]
