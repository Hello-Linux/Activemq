#Docker file for Mister wang
#version:v1.0.1
#date:2017-05-09
#download shpnc web docker monitor
FROM hellolinux/activemq:1.0
#record the author's information
MAINTAINER sun~shell <hello_linux@aliyun.com>
#install java environment
RUN cd /usr/local && wget -c --no-check-certificate --progress=bar --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u101-b13/jdk-8u101-linux-x64.tar.gz" && tar -zxvf jdk-8u101-linux-x64.tar.gz
ENV JAVA_HOME /usr/local/jdk1.8.0_101
ENV JAVA_BIN /usr/local/jdk1.8.0_101/bin
ENV PATH $PATH:$JAVA_BIN
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
#open the port for web
EXPOSE 22 8161 61613 61614 61616
#the daemon's user
USER root
#run some command in the monitor
RUN rpm -Uvh http://mirrors.sohu.com/fedora-epel/6/x86_64/epel-release-6-8.noarch.rpm && yum install supervisor -y && mkdir -p /var/log/supervisor 
#get activemq package
ADD apache-activemq-5.14.5-bin.tar.gz /usr/local/
#mount data for local server
VOLUME ["/usr/local/apache-activemq-5.14.5/data"]
#Label
LABEL version="1.0" location="China" type="Data Center" role="activemq Server"
#add variables
ENV HOSTNAME activemq.shopnc.com
#dir
ENV WORKER_DIR=/ number=1
WORKDIR $WORKER_DIR
#Docker Build
ARG build_version=v1.0.0
ARG webapp_user=activemq
#build
ONBUILD RUN echo "$number++" > /tmp/number.txt
#edit the activemq configure file
RUN \
   sed -i '51a ACTIVEMQ_OPTS_MEMORY=" -server -Xmx2g -Xms2g"\nACTIVEMQ_HOME="/usr/local/apache-activemq-5.14.5/"\nACTIVEMQ_CONF="/usr/local/apache-activemq-5.14.5/conf"' /usr/local/apache-activemq-5.14.5/bin/activemq && \
   sed -i '20,21cadmin: activemq!@#20166102, admin\nactivemq: activemq!@#20166102, admin' /usr/local/apache-activemq-5.14.5/conf/jetty-realm.properties && \
   sed -i '18cadmin=activemq!@#20166102\nactivemq=activemq!@#20166102' /usr/local/apache-activemq-5.14.5/conf/users.properties && \
   sed -i '20,22cactivemq.username=activemq\nactivemq.password=activemq!@#20166102\nguest.password=password' /usr/local/apache-activemq-5.14.5/conf/credentials.properties && \
   sed -i '18cadmins=admin,activemq' /usr/local/apache-activemq-5.14.5/conf/groups.properties && \
   sed -i '97cUsePAM no' /etc/ssh/sshd_config && \
   sed -i '42cPermitRootLogin yes' /etc/ssh/sshd_config
#ADD configuration
COPY config /tmp/
#copy configuration to directory
RUN cp /tmp/supervisord.conf /etc/supervisord.conf && cp /tmp/activemq.xml /usr/local/apache-activemq-5.14.5/conf/
#run supervisord
CMD ["/usr/bin/supervisord"]
