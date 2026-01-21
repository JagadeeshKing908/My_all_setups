#!/bin/bash
set -e

echo "===== Updating system ====="
yum update -y

echo "===== Installing Jenkins repo ====="
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "===== Installing Java 17, Jenkins, Git ====="
yum install -y java-17-amazon-corretto jenkins git

echo "===== Creating Jenkins temp directory ====="
mkdir -p /var/lib/jenkins/tmp
chown -R jenkins:jenkins /var/lib/jenkins
chmod 755 /var/lib/jenkins/tmp

echo "===== Jenkins environment config ====="
cat <<EOF > /etc/sysconfig/jenkins
JENKINS_USER="jenkins"
JENKINS_PORT="8080"
JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Djava.io.tmpdir=/var/lib/jenkins/tmp"
EOF

echo "===== Systemd dependency fix ====="
mkdir -p /etc/systemd/system/jenkins.service.d
cat <<EOF > /etc/systemd/system/jenkins.service.d/override.conf
[Unit]
After=network.target local-fs.target
RequiresMountsFor=/var/lib/jenkins
EOF

echo "===== Reloading systemd ====="
systemctl daemon-reload

echo "===== Enabling Jenkins ====="
systemctl enable jenkins

echo "===== Starting Jenkins ====="
systemctl start jenkins

echo "===== Jenkins Status ====="
systemctl status jenkins --no-pager


reboot


systemctl status jenkins
df -h /tmp
ps -ef | grep jenkins
