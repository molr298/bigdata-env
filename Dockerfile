FROM ubuntu
RUN apt update && apt install -y openssh-server openssh-client vim openjdk-8-jdk
RUN apt update && apt install -y python3-pip && pip3 install mrjob

# SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys


# CONFIG JAVA ENVINROMENT VARIBLES
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64


# HADOOP
RUN wget https://downloads.apache.org/hadoop/common/hadoop-3.2.3/hadoop-3.2.3.tar.gz
RUN tar -xzf hadoop-3.2.3.tar.gz
RUN mv hadoop-3.2.3 usr/local/hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV CONF_DIR $HADOOP_HOME/etc/hadoop
ENV PATH $HADOOP_HOME/sbin:$PATH


# HADOOP - CREATE DIRECTORY FOR STORING DOCUMENTS
RUN mkdir /home/hadoop /home/hadoop/hdfs
RUN mkdir /home/hadoop/tmpdata /home/hadoop/hdfs/namenode /home/hadoop/hdfs/datanode
RUN chmod 777 /home/hadoop/hdfs/namenode
RUN chmod 777 /home/hadoop/tmpdata
RUN chmod 777 /home/hadoop/hdfs/datanode

ADD configurations/start-dfs.sh $HADOOP_HOME/sbin
ADD configurations/stop-dfs.sh $HADOOP_HOME/sbin
ADD configurations/start-yarn.sh $HADOOP_HOME/sbin
ADD configurations/stop-yarn.sh $HADOOP_HOME/sbin
ADD configurations/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD configurations/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD configurations/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD configurations/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml

ENV PATH $HADOOP_HOME/bin:$PATH


# SPARK
RUN wget https://downloads.apache.org/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz
RUN tar xvf spark-3.1.2-bin-hadoop3.2.tgz
RUN mv spark-3.1.2-bin-hadoop3.2 /usr/local/spark
ENV SPARK_HOME /usr/local/spark
ENV PATH $SPARK_HOME/sbin:$PATH
ENV PATH $SPARK_HOME/bin:$PATH


# HBASE
RUN wget https://downloads.apache.org/hbase/2.4.12/hbase-2.4.12-bin.tar.gz
RUN tar xvf hbase-2.4.12-bin.tar.gz
RUN mv hbase-2.4.12 /usr/local/hbase
RUN mkdir /usr/local/zookeeper
RUN chmod 777 /usr/local/zookeeper
ENV HBASE_HOME /usr/local/hbase
ENV PATH $HBASE_HOME/bin:$PATH

ADD configurations/hbase-site.xml $HADOOP_HOME/conf/hbase-site.xml

RUN export HDFS_NAMENODE_USER="root"
RUN export HDFS_DATANODE_USER="root"
RUN export HDFS_SECONDARYNAMENODE_USER="root"
RUN export YARN_RESOURCEMANAGER_USER="root"
RUN export YARN_NODEMANAGER_USER="root"

# FORMAT NAMENODE
ARG FORMAT_NAMENODE_COMMAND
RUN $FORMAT_NAMENODE_COMMAND
EXPOSE 22
