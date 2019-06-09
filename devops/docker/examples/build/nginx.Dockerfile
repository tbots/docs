FROM nginx:latest

RUN  apt update --yes && apt upgrade --yes

#EXPOSE "8080:80"
CMD ["nginx", "-g", "daemon off;" ]     # how to read this shit?!
