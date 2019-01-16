#!/bin/bash

: ${HADOOP_HOME:=/usr/local/hadoop}

bash $HADOOP_HOME/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

/usr/sbin/sshd


# Start the dfs and yarn server if user selected to launch a master node
if [[ $1 == "master" ]]; then
	echo "Starting up the dfs, yarn and mapreduce daemon"
	$HADOOP_HOME/bin/hdfs namenode -format
    $HADOOP_HOME/sbin/start-dfs.sh
    $HADOOP_HOME/sbin/start-yarn.sh
    $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver
    /bin/bash
fi

# Performing cleanup
if [[ $1 == "master" ]]; then
	echo "Stopping up the dfs, yarn and mapreduce daemon"
    $HADOOP_HOME/sbin/stop-dfs.sh
    $HADOOP_HOME/sbin/stop-yarn.sh
fi

# if user selected to launch a client node
if [[ $1 == "slave" ]]; then
	echo "Starting the slave node"
	/bin/bash
fi
