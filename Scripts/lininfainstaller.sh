#!/bin/sh

#Script arguments
domainHost=$1
domainName=$2
domainUser=$3
domainPassword=$4
nodeName=$5
nodePort=$6

dbType=$7
dbName=$8
dbUser=$9
dbPassword=$10
dbHost=$11
dbPort=$12

sitekeyKeyword=$13

joinDomain=$14
osUserName=$15


HDIClusterName=$16
HDIClusterLoginUsername=$17
HDIClusterLoginPassword=$18
HDIClusterSSHHostname=$19
HDIClusterSSHUsername=$20
HDIClusterSSHPassword=$21
Clusterjobhistory=$22
Clusterjobhistorywebapp=$23
ClusterRMSaddress=$24
ClusterRMWaddress=$25

storageName=$26
storageKey=$27

#Usage
if [ $# -ne 27 ]
then
	lininfainstaller.sh domainHost domainName domainUser domainPassword nodeName nodePort dbType dbName dbUser dbPassword dbHost dbPort sitekeyKeyword joinDomain  osUserName HDIClusterName HDIClusterLoginUsername HDIClusterLoginPassword HDIClusterSSHHostname HDIClusterSSHUsername HDIClusterSSHPassword Clusterjobhistory Clusterjobhistorywebapp ClusterRMSaddress ClusterRMWaddress storageName storageKey
fi

apt-get update

CLOUD_SUPPORT_ENABLE=1

dbAddress=$dbHost:$dbPort
hostName=`hostname`


infainstallerloc=/opt/Informatica/Archive/server
infainstallionloc=\\/home\\/$osUserName\\/Informatica\\/10.0.0
infaHome=/home/$osUserName/Informatica/10.0.0
ispBinLocation=$infaHome/isp/bin
hadoopDirLocation=$infaHome/services/shared/hadoop/hortonworks_2.2
hadoopYarnConfDirLocation=$hadoopDirLocation/conf
hadoopInfaConfDirLocation=$hadoopDirLocation/infaConf
defaultKeyLocation=$infainstallionloc\\/isp\\/config\\/keys

utilityHome=/opt/Informatica/Archive/Utilities

JAVA_HOME="/opt/Informatica/Archive/server/source/java"
export JAVA_HOME		
PATH="$JAVA_HOME/bin":"$PATH"
export PATH

chmod -R 777 $JAVA_HOME

createDomain=1
if [ $joinDomain -eq 1 ]
then
    createDomain=0
	# This is buffer time for master node to start
	sleep 300
else
	cd $utilityHome
    java -jar iadutility.jar createAzureFileShare -storageaccesskey $storageKey -storagename $storageName
fi

apt-get install cifs-utils
mountDir=/mnt/infaaeshare
mkdir $mountDir
mount -t cifs //$storageName.file.core.windows.net/infaaeshare $mountDir -o vers=3.0,username=$storageName,password=$storageKey,dir_mode=0777,file_mode=0777
echo //$storageName.file.core.windows.net/infaaeshare $mountDir cifs vers=3.0,username=$storageName,password=$storageKey,dir_mode=0777,file_mode=0777 >> /etc/fstab

sed -i s/^USER_INSTALL_DIR=.*/USER_INSTALL_DIR=$infainstallionloc/ $infainstallerloc/SilentInput.properties

sed -i s/^CREATE_DOMAIN=.*/CREATE_DOMAIN=$createDomain/ $infainstallerloc/SilentInput.properties

sed -i s/^JOIN_DOMAIN=.*/JOIN_DOMAIN=$joinDomain/ $infainstallerloc/SilentInput.properties

sed -i s/^CLOUD_SUPPORT_ENABLE=.*/CLOUD_SUPPORT_ENABLE=$CLOUD_SUPPORT_ENABLE/ $infainstallerloc/SilentInput.properties

sed -i s/^ENABLE_USAGE_COLLECTION=.*/ENABLE_USAGE_COLLECTION=1/ $infainstallerloc/SilentInput.properties

sed -i s/^KEY_DEST_LOCATION=.*/KEY_DEST_LOCATION=$defaultKeyLocation/ $infainstallerloc/SilentInput.properties

sed -i s/^PASS_PHRASE_PASSWD=.*/PASS_PHRASE_PASSWD=$sitekeyKeyword/ $infainstallerloc/SilentInput.properties

sed -i s/^SERVES_AS_GATEWAY=.*/SERVES_AS_GATEWAY=1/ $infainstallerloc/SilentInput.properties

sed -i s/^DB_TYPE=.*/DB_TYPE=$dbType/ $infainstallerloc/SilentInput.properties

sed -i s/^DB_UNAME=.*/DB_UNAME=$dbUser/ $infainstallerloc/SilentInput.properties

sed -i s/^DB_PASSWD=.*/DB_PASSWD=$dbPassword/ $infainstallerloc/SilentInput.properties

sed -i s/^DB_SERVICENAME=.*/DB_SERVICENAME=$dbName/ $infainstallerloc/SilentInput.properties

sed -i s/^DB_ADDRESS=.*/DB_ADDRESS=$dbAddress/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_NAME=.*/DOMAIN_NAME=$domainName/ $infainstallerloc/SilentInput.properties

sed -i s/^NODE_NAME=.*/NODE_NAME=$nodeName/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_PORT=.*/DOMAIN_PORT=$nodePort/ $infainstallerloc/SilentInput.properties

sed -i s/^JOIN_NODE_NAME=.*/JOIN_NODE_NAME=$nodeName/ $infainstallerloc/SilentInput.properties

sed -i s/^JOIN_HOST_NAME=.*/JOIN_HOST_NAME=$hostName/ $infainstallerloc/SilentInput.properties

sed -i s/^JOIN_DOMAIN_PORT=.*/JOIN_DOMAIN_PORT=$nodePort/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_USER=.*/DOMAIN_USER=$domainUser/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_HOST_NAME=.*/DOMAIN_HOST_NAME=$domainHost/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_PSSWD=.*/DOMAIN_PSSWD=$domainPassword/ $infainstallerloc/SilentInput.properties

sed -i s/^DOMAIN_CNFRM_PSSWD=.*/DOMAIN_CNFRM_PSSWD=$domainPassword/ $infainstallerloc/SilentInput.properties

cd $infainstallerloc
echo Y Y | sh silentinstall.sh 

infainstallionlocown=/home/$osUserName/Informatica

chown -R $osUserName $infainstallionlocown
chown -R $osUserName /opt/Informatica 
chown -R $osUserName /mnt/infaaeshare
#INFA BINARIES TO CLUSTER : RPM Installation - Start
echo $osUserName $HDIClusterName $HDIClusterLoginUsername $HDIClusterLoginPassword $HDIClusterSSHHostname $HDIClusterSSHUsername $HDIClusterSSHPassword 

mkdir /home/$osUserName/infaRPMInstall
cd /home/$osUserName/infaRPMInstall
wget http://ispstorenp.blob.core.windows.net/bderpm/informatica_10.0.0-1.deb

#Ambari API calls to extract Head node and Data nodes
echo "Getting list of hosts from ambari"
hostsJson=$(curl -u $HDIClusterLoginUsername:$HDIClusterLoginPassword -X GET https://$HDIClusterName.azurehdinsight.net/api/v1/clusters/$HDIClusterName/hosts)
echo $hostsJson 

echo "Parsing list of hosts"
hosts=$(echo $hostsJson | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w 'host_name')
echo $hosts

echo "Extracting headnode0"
headnode0=$(echo $hosts | grep -Eo '\bhn0-([^[:space:]]*)\b') 
echo $headnode0
echo "Extracting headnode0 IP addresses"
headnode0ip=$(dig +short $headnode0) 
echo "headnode0 IP: $headnode0ip"

#Add a new line to the end of hosts file
echo "">>/etc/hosts
echo "Adding headnode IP addresses"
echo "$headnode0ip headnode0">>/etc/hosts

echo "Extracting workernode"
workernodes=$(echo $hosts | grep -Eo '\bwn([^[:space:]]*)\b') 
echo "Extracting workernodes IP addresses"
echo "workernodes : $workernodes" 
wnArr=$(echo $workernodes | tr "\n" "\n")
#tmpRemoteFolderName = rpmtemp
#filename = informatica_10.0.0-1.deb
sudo apt-get install sshpass
for workernode in $wnArr
do
    echo "[$workernode]" 
	workernodeip=$(dig +short $workernode)
	echo "workernodeip $workernodeip" 
	#create temp folder
	sudo sshpass -p $HDIClusterSSHPassword ssh -o StrictHostKeyChecking=no $HDIClusterSSHUsername@$workernodeip "sudo mkdir ~/rpmtemp" 
	#Give permission to rpm folder
	sudo sshpass -p $HDIClusterSSHPassword ssh -o StrictHostKeyChecking=no $HDIClusterSSHUsername@$workernodeip "sudo chmod 777 ~/rpmtemp"
	#SCP infa binaries
	sudo sshpass -p $HDIClusterSSHPassword scp informatica_10.0.0-1.deb $HDIClusterSSHUsername@$workernodeip:"~/rpmtemp/" 
	#extract the binaries
	sudo sshpass -p $HDIClusterSSHPassword ssh -o StrictHostKeyChecking=no $HDIClusterSSHUsername@$workernodeip "sudo dpkg -i ~/rpmtemp/informatica_10.0.0-1.deb"
	#Clean the temp folder
	sudo sshpass -p $HDIClusterSSHPassword ssh -o StrictHostKeyChecking=no $HDIClusterSSHUsername@$workernodeip "sudo rm -rf ~/rpmtemp"
done

cd /home/$osUserName
rm -rf /home/$osUserName/infaRPMInstall
#INFA BINARIES TO CLUSTER : RPM Installation - End
#Updating yarn site - Start
echo $Clusterjobhistory $Clusterjobhistorywebapp $ClusterRMSaddress $ClusterRMWaddress
sed -i '/<configuration>/ a <property>\n<name>mapreduce.jobhistory.address</name>\n<value>'$Clusterjobhistory'</value>\n<description>MapReduce JobHistory Server IPC host:port</description>\n</property>' $hadoopYarnConfDirLocation/yarn-site.xml
sed -i '/<configuration>/ a <property>\n<name>mapreduce.jobhistory.webapp.address</name>\n<value>'$Clusterjobhistorywebapp'</value>\n<description>MapReduce JobHistory Server Web UI host:port</description>\n</property>' $hadoopYarnConfDirLocation/yarn-site.xml
sed -i '/<configuration>/ a <property>\n<name>yarn.resourcemanager.scheduler.address</name>\n<value>'$ClusterRMSaddress'</value>\n<description>CLASSPATH for YARN applications. A comma-separated list of CLASSPATH entries</description>\n</property>' $hadoopYarnConfDirLocation/yarn-site.xml
sed -i '/<configuration>/ a <property>\n<name>yarn.resourcemanager.webapp.address</name>\n<value>'$ClusterRMWaddress'</value>\n<description>CLASSPATH for YARN applications. A comma-separated list of CLASSPATH entries</description>\n</property>' $hadoopYarnConfDirLocation/yarn-site.xml
#Updating yarn site - End

#Cluster Connection creation - Start
cd $ispBinLocation
#HadoopClusterConnection
sh infacmd.sh createConnection -un $domainUser -pd $domainPassword -ct Hadoop -dn $domainName -cn HDIClusterConnection -o RMAddress=$headnode0ip:8050 cadiMaxPort=9200 cadiMinPort=9100 cadiUserName=$HDIClusterSSHUsername cadiWorkingDirectory=/tmp databaseName=default defaultFSURI=hdfs://$headnode0ip:8020 engineType=MRv2 hiveWarehouseDirectoryOnHDFS=/hive/warehouse jobMonitoringURL=$headnode0ip:8088 metastoreMode=remote remoteMetastoreURI=thrift://$headnode0ip:9083
#HDFS Connection
sh infacmd.sh createConnection -un $domainUser -pd $domainPassword -ct HadoopFileSystem -dn $domainName -cn HDIHDFSConnection -o nameNodeURL=hdfs://$headnode0ip:8020 userName=$HDIClusterSSHUsername
#Cluster Connection creation - End