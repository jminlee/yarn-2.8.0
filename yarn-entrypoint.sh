#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

/bin/rm -rf /tmp/*.pid

# Get the namenode host address
if [ -z $HADOOP_HOST_NAMENODE ]; then 
 HADOOP_HOST_NAMENODE=namenode;
 echo "No namenode passed, setting short hostname to namenode. Pass in a value for HADOOP_HOST_NAMENODE to set namenode host.";
fi

if [ ! -e  $HADOOP_PREFIX/etc/hadoop/core-site.xml ]
then
        echo "Changing Hostname in core-site.xml"
        sed s/HOSTNAME/$HADOOP_HOST_NAMENODE/ $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml
else
        echo "core-site.xml exists: "
        cat $HADOOP_PREFIX/etc/hadoop/core-site.xml
fi

# Fudge hostname/ip config for yarn-config
echo "Current Hostname: " `hostname`
if [ ! -e  $HADOOP_PREFIX/etc/hadoop/yarn-site.xml ]
then
  	echo "Changing Hostname in yarn-site.xml"
	sed s/HOSTNAME/`hostname`/ $HADOOP_PREFIX/etc/hadoop/yarn-site.xml.template > $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
else
	echo "yarn-site.xml: "
	cat $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
fi

# Change Yarn & history server hostname in mapred-site.xml
if [ ! -e  $HADOOP_PREFIX/etc/hadoop/mapred-site.xml ]
then
        echo "Changing Hostname in mapred-site.xml"
        sed s/HOSTNAME/`hostname`/ $HADOOP_PREFIX/etc/hadoop/mapred-site.xml.template > $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
else
        echo "mapred-site.xml: "
        cat $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
fi

echo "Starting Resourcemanager"
$HADOOP_PREFIX/sbin/yarn-daemon.sh start resourcemanager

echo "Starting Job History Server"
$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver

# Start SSHD 
echo "Starting sshd"
exec /usr/sbin/sshd -D

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

