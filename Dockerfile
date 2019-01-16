FROM ubuntu:16.04

# Install Java8 and ssh-server
RUN apt-get update && \
    apt-get install -y  software-properties-common && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get install -y openssh-server

# Create Java environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java
RUN export JAVA_HOME

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f

# Generate ssh keys for password-less communication
RUN yes y |ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN yes y |ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN yes y |ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN mkdir /var/run/sshd

COPY configs/ssh_config /root/.ssh/config
COPY configs/sshd_config /etc/ssh/sshd_config

RUN chmod 600 /root/.ssh/
RUN chown root:root /root/.ssh/

# SSH Port
EXPOSE 22

# Hadoop Environment variables
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Install Hadoop
RUN wget https://dist.apache.org/repos/dist/release/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
RUN tar -xzvf hadoop-2.7.7.tar.gz
RUN rm -f hadoop-2.7.7.tar.gz
RUN mv hadoop-2.7.7 $HADOOP_HOME
RUN echo "export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")"> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN export PATH=$PATH:$HADOOP_HOME/bin

# Copy hadoop configuration files
COPY hadoop_configs/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY hadoop_configs/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
COPY hadoop_configs/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
COPY hadoop_configs/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY hadoop_configs/slaves $HADOOP_HOME/etc/hadoop/slaves

RUN chown root:root $HADOOP_HOME

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Run the boostrap script to initialise the hadoop, dfs and yarn
ENTRYPOINT ["./entrypoint.sh"]
CMD []
