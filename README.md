# Hadoop Cluster using Docker
[![N|Solid](https://secure.gravatar.com/avatar/7273c58dc017eec83667b50742ff6368?s=80)](https://www.linkedin.com/in/amitasviper/)

## Build the image
To build the image directly from the Dockerfile you could use the following command
```docker build  -t amitasviper/hadoop-cluster:latest .```

## Pull from docker registry
This image is also published on the docker registry under the username `amitasviper`. To pull the image just execute the following command.
```docker pull amitasviper/hadoop-cluster:latest```

## Run Namenodes and Datanodes
While running the containers using this image, you could specify the container to be namenode or datanode using the commandline arguments.

To create a hadoop cluster(1 Name node + 2 Data node) you could use the following procedure.
1. Create a docker virtual network in which all these nodes will reside. This can be acheived by the following command ```docker network create --subnet=172.18.0.0/16 hadoopnet```.
2. Now start the two slave nodes by executing these two commands.
```docker run  --net hadoopnet --ip 172.18.0.3 --hostname node2 --add-host nodemaster:172.18.0.2 --add-host node3:172.18.0.4 --name node2 -it amitasviper/hadoop-cluster slave```

    ```docker run --net hadoopnet --ip 172.18.0.4 --hostname node3 --add-host nodemaster:172.18.0.2 --add-host node2:172.18.0.3 --name node3 -it amitasviper/hadoop-cluster slave```
3. Finally start the master namenode using the following command.
```docker run --net hadoopnet --ip 172.18.0.2 --hostname nodemaster --add-host node3:172.18.0.4 --add-host node2:172.18.0.3 --name nodemaster -it  -p 50070:50070  -p 8088:8088 amitasviper/hadoop-cluster master```

