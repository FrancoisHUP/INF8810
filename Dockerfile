# Use an official OpenJDK base image
FROM openjdk:11-slim

# Set environment variables for Hadoop
ENV HADOOP_VERSION 3.3.6
ENV HADOOP_URL https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# Set JAVA_HOME and add it to PATH
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Install required packages including the JDK and SSH
RUN apt-get update && \
    apt-get install -y wget tar openjdk-11-jdk ssh net-tools && \
    apt-get clean

# Download and extract Hadoop
RUN wget $HADOOP_URL && \
    tar -xzf hadoop-$HADOOP_VERSION.tar.gz -C /usr/local && \
    mv /usr/local/hadoop-$HADOOP_VERSION $HADOOP_HOME && \
    rm hadoop-$HADOOP_VERSION.tar.gz

# Set Hadoop configuration
COPY configs/core-site.xml $HADOOP_HOME/etc/hadoop/
COPY configs/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY configs/mapred-site.xml $HADOOP_HOME/etc/hadoop/
COPY configs/yarn-site.xml $HADOOP_HOME/etc/hadoop/
COPY configs/hadoop-env.sh $HADOOP_HOME/etc/hadoop/

# Set up SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# Configure SSH
RUN echo "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null" >> /root/.ssh/config

# Create a script to start Hadoop services
RUN echo '#!/bin/bash\n\
    /etc/init.d/ssh start\n\
    echo "127.0.0.1 localhost" >> /etc/hosts\n\
    $HADOOP_HOME/bin/hdfs namenode -format\n\
    $HADOOP_HOME/sbin/start-dfs.sh\n\
    $HADOOP_HOME/sbin/start-yarn.sh\n\
    tail -f $HADOOP_HOME/logs/*' > /usr/local/start-hadoop.sh && \
    chmod +x /usr/local/start-hadoop.sh

# Set Hadoop-related environment variables
ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

# Ensure JAVA_HOME is set in Hadoop configuration
RUN echo "export JAVA_HOME=${JAVA_HOME}" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Configure Hadoop to use SSH instead of PDSH
RUN echo "export HADOOP_SSH_OPTS=\"-o StrictHostKeyChecking=no\"" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export PDSH_RCMD_TYPE=ssh" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Set the working directory
WORKDIR $HADOOP_HOME

# Expose necessary ports
EXPOSE 50070 8088 9000 22

# Start Hadoop services
CMD ["/usr/local/start-hadoop.sh"]