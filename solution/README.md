[root@InfraCloudTest opt]# docker pull infracloudio/csvserver:latest
latest: Pulling from infracloudio/csvserver
ae43b40a9945: Pull complete
7bb33bb2db38: Pull complete
c82d72e1bb76: Pull complete
Digest: sha256:20bc5a93fac217270fe5c88d639d82c6ecb18fc908283e046d9a3917a840ec1f
Status: Downloaded newer image for infracloudio/csvserver:latest
docker.io/infracloudio/csvserver:latest
[root@InfraCloudTest opt]#
[root@InfraCloudTest opt]#
[root@InfraCloudTest opt]#
[root@InfraCloudTest opt]# docker pull prom/prometheus:v2.22.0
v2.22.0: Pulling from prom/prometheus
76df9210b28c: Pull complete
559be8e06c14: Pull complete
Digest: sha256:60190123eb28250f9e013df55b7d58e04e476011911219f5cedac3c73a8b74e6
Status: Downloaded newer image for prom/prometheus:v2.22.0
docker.io/prom/prometheus:v2.22.0
[root@InfraCloudTest opt]#
[root@InfraCloudTest opt]#
[root@InfraCloudTest opt]#
[root@InfraCloudTest opt]# git clone https://github.com/infracloudio/csvserver.git
Cloning into 'csvserver'...
remote: Enumerating objects: 24, done.
remote: Counting objects: 100% (24/24), done.
remote: Compressing objects: 100% (14/14), done.
remote: Total 24 (delta 6), reused 24 (delta 6), pack-reused 0
Unpacking objects: 100% (24/24), done.
[root@InfraCloudTest opt]#
[root@InfraCloudTest opt]#
[root@InfraCloudTest opt]# ls -lrt
total 0
drwxr-xr-x. 2 root root  6 Oct 30  2018 rh
drwx--x--x. 4 root root 28 Sep 28 03:22 containerd
drwxr-xr-x. 4 root root 51 Sep 28 03:31 csvserver
[root@InfraCloudTest opt]#


[root@InfraCloudTest solution]# docker run --name csvserver -d infracloudio/csvserver
f9b7c6c871364436c17e1fa923b415e6c0207ef7061f4a271cb1378cd68dcc93
[root@InfraCloudTest solution]#


[root@InfraCloudTest solution]# docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS                     PORTS     NAMES
f9b7c6c87136   infracloudio/csvserver   "/csvserver/csvserver"   6 seconds ago   Exited (1) 5 seconds ago             csvserver
[root@InfraCloudTest solution]#


[root@InfraCloudTest solution]#
[root@InfraCloudTest solution]# docker logs csvserver
2022/09/28 03:35:24 error while reading the file "/csvserver/inputdata": open /csvserver/inputdata: no such file or directory
[root@InfraCloudTest solution]#


[root@InfraCloudTest solution]# cat gencsv.sh
#!/bin/bash

if [ $# -eq 0 ];
then
   number=10
else
   number=$1
fi

for i in `seq $number`
do
echo $i, $RANDOM
done
[root@InfraCloudTest solution]#

[root@InfraCloudTest solution]# ./gencsv.sh > inputFile
[root@InfraCloudTest solution]# ls -lrt
total 8
-rwxr--r--. 1 root root 119 Sep 28 03:59 gencsv.sh
-rw-r--r--. 1 root root  89 Sep 28 04:24 inputFile
[root@InfraCloudTest solution]#

[root@InfraCloudTest solution]# ./gencsv.sh > inputdata
[root@InfraCloudTest solution]# ls -lrt
total 12
-rwxr--r--. 1 root root 119 Sep 28 03:59 gencsv.sh
-rw-r--r--. 1 root root  86 Sep 28 04:25 inputFile
-rw-r--r--. 1 root root  90 Sep 28 04:27 inputdata
[root@InfraCloudTest solution]#
[root@InfraCloudTest solution]#

As the file missing in the container was inputdata so we created that file and copied it into the container.

[root@InfraCloudTest solution]#
[root@InfraCloudTest solution]# docker cp inputdata csvserver:/csvserver/
[root@InfraCloudTest solution]# echo $?
0
[root@InfraCloudTest solution]#
[root@InfraCloudTest solution]# docker start csvserver
csvserver
[root@InfraCloudTest solution]# docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS         PORTS      NAMES
f9b7c6c87136   infracloudio/csvserver   "/csvserver/csvserver"   53 minutes ago   Up 2 seconds   9300/tcp   csvserver
[root@InfraCloudTest solution]#


The container is running on the 9300/tcp Port

[root@InfraCloudTest solution]# docker stop csvserver
csvserver
[root@InfraCloudTest solution]# docker rm csvserver
csvserver
[root@InfraCloudTest solution]# docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[root@InfraCloudTest solution]#
[root@InfraCloudTest solution]#


[root@InfraCloudTest solution]# docker run --name csvserver -p 9393:9300 --env CSVSERVER_BORDER=Orange -d infracloudio/csvserver
8744b76ad02bf73f677002c27c2bfa17969266890ef93fbd107c2375ad5f5259


[root@InfraCloudTest solution]# docker cp inputdata csvserver:/csvserver/
[root@InfraCloudTest solution]#

OR 

[root@InfraCloudTest solution]# docker run --name csvserver -p 9393:9300 --env CSVSERVER_BORDER=Orange -d infracloudio/csvserver ; docker cp inputdata csvserver:/csvserver/ ; docker start csvserver

Above command will create a container, copy a file and make that container running

[root@InfraCloudTest solution]# docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED              STATUS          PORTS                                       NAMES
8744b76ad02b   infracloudio/csvserver   "/csvserver/csvserver"   About a minute ago   Up 50 seconds   0.0.0.0:9393->9300/tcp, :::9393->9300/tcp   csvserver
[root@InfraCloudTest solution]#


Then we need to enable the Inbound port of 9393 in the Network Security group of our VM on which docker container is running.

Then we would be able to access the application with http://<PublicIP>:9393


