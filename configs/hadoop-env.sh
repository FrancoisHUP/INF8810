export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_SSH_OPTS="-o StrictHostKeyChecking=no"
export PDSH_RCMD_TYPE=ssh

# Set Hadoop-related user variables
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root

# Disable IPv6
export HADOOP_OPTS="$HADOOP_OPTS -Djava.net.preferIPv4Stack=true"