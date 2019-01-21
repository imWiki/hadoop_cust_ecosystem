MSD Assessment to load given file into Hadoop Stack
===================================================

# Pre-Requesites

1. [Any Browser](https://www.google.com/chrome/browser/desktop/index.html) to view the zeppelin and other services
2. [Git](https://git-scm.com/downloads) (Optional to download the contents of this repository)
3. [Vagrant](https://www.vagrantup.com/downloads.html) - Download relevant platform installer & run the setup
4. [VirtualBox](https://www.virtualbox.org/wiki/Downloads) - To run the virtual ubuntu machine with hadoop stack

# Services
The virtual machine will be running the following services:

* HDFS NameNode + DataNode
* YARN ResourceManager/NodeManager + JobHistoryServer + ProxyServer
* Hive metastore and server2
* Spark history server
* Zeppelin Server
* At the end batch script will download csv file & load to hive. PySpark will then load the output table with result dataset which will be visualized in Apache Zeppelin

# Getting Started

1. Download and install VirtualBox & Vagrant with above given links.
2. Clone this repo.
3. In your terminal/cmd change your directory into the project directory (i.e. `cd msd_challenge`).
4. Run `vagrant up --provider=virtualbox` to create the VM using virtualbox as a provider (**NOTE** *This will take a while the first time as many dependencies are downloaded - subsequent deployments will be quicker as dependencies are cached in the `resources` directory*).
5. Execute ```vagrant ssh``` to login to the VM.
6. Execute ```beeline -u 'jdbc:hive2://vigneshm:10000/default;' --color=true -n vagrant -p vagrant``` to login to the hive & see the tables created with requested data loaded. 
7. Main ETL Functionality is implemented within the scripts directory `data_proc.sh` & PySpark is written within `asmt_results.py`

# Work out the ip-address of the virtualbox VM
The ip address of the virtualbox machine should be `10.211.55.101`. Please add this entry to your hosts file in your machine to access the services with hostname instead of IP in browser. Example shown below,

![picture](temp/Host_File_Entry.png)

# Map Reduce - Tez
By default map reduce jobs will be executed via Tez to change this to standard MR, change the following parameter in $HADOOP_CONF/mapred-site.xml from: -

```xml
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn-tez</value>
    </property>
```

to

```xml
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
```

# Web user interfaces

Here are some useful links to navigate to various UI's:

* YARN resource manager:  (http://node1:8088)
* HBase: (http://node1:16010)
* Job history:  (http://node1:19888/jobhistory/)
* HDFS: (http://node1:50070/dfshealth.html)
* Spark history server: (http://node1:18080)
* Spark context UI (if a Spark context is running): (http://node1:4040)

Substitute the ip address of the container or virtualbox VM for `node1` if necessary.

# Shared Folder

Vagrant automatically mounts the folder containing the Vagrant file from the host machine into
the guest machine as `/vagrant` inside the guest.


# Validating your virtual machine setup

To test out the virtual machine setup, and for examples of how to run
MapReduce, Hive and Spark, head on over to [VALIDATING.md](VALIDATING.md).


# Managment of Vagrant VM

To stop the VM and preserve all setup/data within the VM: -

```
vagrant halt
```

or

```
vagrant suspend
```

Issue a `vagrant up` command again to restart the VM from where you left off.

To completely **wipe** the VM so that `vagrant up` command gives you a fresh machine: -

```
vagrant destroy
```

Then issue `vagrant up` command as usual.

# To shutdown services cleanly

```
$ vagrant ssh
$ sudo -sE
$ /vagrant/scripts/stop-spark.sh
$ /vagrant/scripts/stop-hbase.sh
$ /vagrant/scripts/stop-hadoop.sh

```

# Swapspace - Memory

Spark in particular needs quite a bit of memory to run - to work around this a `swapspace` daemon is also configured and
started that uses normal disk to dynamically allocate swapspace when memory is low.

# Problems
Sometimes the Spark UI is not available from the host machine when running with virtualbox. Setting: -

```bash
 export SPARK_LOCAL_IP=10.211.55.101
 spark-shell .....
```
Seems to solve this.

# More advanced setup

If you'd like to learn more about working and optimizing Vagrant then
take a look at [ADVANCED.md](ADVANCED.md).

# For developers

The file [DEVELOP.md](DEVELOP.md) contains some tips for developers.

# Credits

Thanks to [Alex Holmes](https://github.com/alexholmes) for the great work at
(https://github.com/alexholmes/vagrant-hadoop-spark-hive)

[Matheus Cunha](https://github.com/matheuscunha)





cd /home/ubuntu/zeppelin-0.8.0-bin-netinst/bin/
sudo -sE
./zeppelin-daemon.sh restart
