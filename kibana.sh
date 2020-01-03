#!/usr/bin/bash
#author Ten.J
systemctl stop firewalld &> /dev/null
setenforce 0 &> /dev/null

qjpath=`pwd`

#ELK-kibana所需用到的所有tar包
java_tar='jdk-8u211-linux-x64.tar.gz'
kibana_tar='kibana-6.5.4-linux-x86_64.tar.gz'

if [ ! -e $qjpath/$java_tar ]
then
	yum -y install java
else
	echo '开始部署java环境。。。'
	tar xf $qjpath/$java_tar -C /usr/local/
	mv /usr/local/jdk1.8.0_211 /usr/local/java
	echo 'JAVA_HOME=/usr/local/java' >> /etc/profile.d/java.sh
	echo 'PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile.d/java.sh
	echo 'export JAVA_HOME PATH' >> /etc/profile.d/java.sh
	source /etc/profile.d/java.sh
fi	

if [ ! -e $qjpath/$kibana_tar ]
then
	yum -y install wget
	wget https://artifacts.elastic.co/downloads/kibana/$kibana_tar
fi


sleep 1
#配置kibana
echo '开始配置kibana。。。'
tar xf $qjpath/$kibana_tar -C /usr/local/
mv /usr/local/kibana-6.5.4-linux-x86_64 /usr/local/kibana

#server.host为kibana主机IP地址，直接用本机的即可
server_host=`ip a | grep inet|grep brd|awk '{print $2}'|awk -F/ '{print $1}'` #获取当前ip

#elasticsearch.url用一个es节点的ip
elasticsearch_url='http://172.31.138.140:9200'

echo '
server.port: 5601
server.host: "'$server_host'"
elasticsearch.url: "'$elasticsearch_url'"
kibana.index: ".kibana"
' > /usr/local/kibana/config/kibana.yml

#启动
nohup /usr/local/kibana/bin/kibana &
sleep 7
netstat -ntlp |grep '5601'
if [ $? -eq 0 ]
then
	sleep 
	echo 'kibana配置已完成，已启动'
fi
