#!/bin/bash

# 所有容器已经启动，我们按步骤执行我们需要的命令
:<<COMMENT
1. 启动journalnode（分别在node03、node04、node05上执行启动）
/usr/local/hadoop/sbin/hadoop-daemon.sh start journal-node
运行jps命令检验，node03、node04、node05上多了JournalNode进程
COMMENT
# 本步骤已经放入镜像完成

:<<COMMENT
2. 格式化HDFS
在node01上执行命令:
/usr/local/hadoop/bin/hdfs namenode -format
格式化成功之后会在core-site.xml中的hadoop.tmp.dir指定的路径下生成dfs文件夹，将该文件夹拷贝到node02的相同路径下
docker exec -it /usr/local/hadoop/bin/hdfs namenode -format
格式化成功之后会在core-site.xml中的hadoop.tmp.dir指定的路径下生成dfs文件夹，将该文件夹拷贝到node02的相同路径下
scp -r /mnt/hadoop/dfs/data/* root@node02:/mnt/hadoop/dfs/data
注意：不执行此步骤，namenode slave 会启动不起来
COMMENT
docker exec -it node01 bash -c 'echo slave01 > etc/hadoop/slaves'
docker exec -it node02 bash -c 'echo slave01 > etc/hadoop/slaves'
docker exec -it node01 bash -c '/usr/local/hadoop/bin/hdfs namenode -format; scp -r /mnt/hadoop/dfs/data/* root@node02:/mnt/hadoop/dfs/data'

:<<COMMENT
3. 在node01上执行格式化ZKFC操作
/usr/local/hadoop/bin/hdfs zkfc -formatZK
执行成功，日志输出如下信息
INFO ha.ActiveStandbyElector: Successfully created /hadoop-ha/ns in ZK
4. 在node01上启动HDFS
/usr/local/hadoop/sbin/start-dfs.sh

/usr/local/hadoop/bin/hdfs haadmin -getServiceState nn1

5. 在node02上启动YARN
/usr/local/hadoop/sbin/start-yarn.sh
在node01单独启动一个ResourceManger作为备份节点
/usr/local/hadoop/sbin/yarn-daemon.sh start resourcemanager

查看主备
/usr/local/hadoop/bin/yarn rmadmin -getServiceState rm2

6. 在node02上启动JobHistoryServer
/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver
启动完成node02会增加一个JobHistoryServer进程

COMMENT
docker exec -it node01 bash -c '/usr/local/hadoop/bin/hdfs zkfc -formatZK; /usr/local/hadoop/sbin/start-dfs.sh'
docker exec -it node02 bash -c '/usr/local/hadoop/sbin/start-yarn.sh'
docker exec -it node01 bash -c '/usr/local/hadoop/sbin/yarn-daemon.sh start resourcemanager'
docker exec -it node02 bash -c '/usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver'

echo  -e "HDFS HTTP 访问地址\n"
echo  -e "NameNode (active): http://localhost:50070\n"
echo  -e "NameNode (standby): http://localhost:50071\n"
echo  -e "ResourceManager HTTP访问地址\n"
echo  -e "ResourceManager: http://localhost:8081\n"
echo  -e "历史日志HTTP访问地址\n"
echo  -e "JobHistoryServer: http://localhost:19889\n"