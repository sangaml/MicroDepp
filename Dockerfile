FROM centos:centos7

RUN yum install -y epel-release

RUN yum install -y nodejs npm

WORKDIR ./myapp

COPY employee.txt .

COPY department.txt .

COPY version.txt .

COPY main.js .

EXPOSE 3000

CMD ["node","main.js"]
