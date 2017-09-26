#!/bin/sh
# -------------------------------------------------------------------------------
# Filename:    install.sh
# Revision:    1.0
# Date:        2017/09/20
# Author:      bishenghua
# Email:       net.bsh@gmail.com
# Description: Script to install the kubernets system
# -------------------------------------------------------------------------------
# Copyright:   2017 (c) Bishenghua
# License:     GPL
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# you should have received a copy of the GNU General Public License
# along with this program (or with Nagios);
#
# Credits go to Ethan Galstad for coding Nagios
# If any changes are made to this script, please mail me a copy of the changes
# -------------------------------------------------------------------------------

echo -e "\033[32m{`date`}[开始]初始化安装.............................\033[0m"
while true
do 
    yum -y install epel-release net-tools vim python-pip python-setuptools bzip2 unzip telnet
    which pip > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        break
    fi
done
while true
do
    pip install fabric
    pip install --upgrade pip
    which fab > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        break
    fi
done
tar zxvf source/needbin.gz -C /
echo -e "\033[32m{`date`}[结束]初始化安装.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]安装基础环境.............................\033[0m"
fab install_base
echo -e "\033[32m{`date`}[结束]安装基础环境.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]安装docker.............................\033[0m"
fab install_docker
echo -e "\033[32m{`date`}[结束]安装docker.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]安装docker私有仓库.............................\033[0m"
fab install_pridocker
echo -e "\033[32m{`date`}[结束]安装docker私有仓库.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]安装etcd.............................\033[0m"
fab install_etcd
echo -e "\033[32m{`date`}[结束]安装etcd.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]安装master节点.............................\033[0m"
fab install_master
echo -e "\033[32m{`date`}[结束]安装master节点.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]安装node节点.............................\033[0m"
fab install_node
echo -e "\033[32m{`date`}[结束]安装node节点.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]安装flannel节点.............................\033[0m"
fab install_flannel
echo -e "\033[32m{`date`}[结束]安装flannel节点.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]安装docker证书.............................\033[0m"
fab install_dockercrt
echo -e "\033[32m{`date`}[结束]安装docker证书.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]安装负载均衡.............................\033[0m"
fab install_lvs
echo -e "\033[32m{`date`}[结束]安装负载均衡.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]安装dns.............................\033[0m"
fab install_dns
echo -e "\033[32m{`date`}[结束]安装dns.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]启动所有服务.............................\033[0m"
fab service:restart
# 有可能flanneld启动太快，导致docker网络没被覆盖，这里重启一下flannel和docker
fab service_flannel_docker:restart
echo -e "\033[32m{`date`}[结束]启动所有服务.............................\n\n\n\n\n\n\033[0m"


#!/bin/sh

echo -e "\033[32m{`date`}[开始]验证k8s集群.............................\033[0m"
i=0
while true
do
    sleep 1
    ((i++))
    echo -e "\033[32m等待倒计时($i)s...\033[0m"
    kubectl get nodes -o wide | grep NotReady
    if [ $? -ne 0 ]; then
        kubectl get nodes -o wide
        break
    fi
done
echo -e "\033[32m{`date`}[结束]验证k8s集群.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]初始化镜像.............................\033[0m"
fab init_images
echo -e "\033[32m{`date`}[结束]初始化镜像.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]初始k8s系统镜像服务.............................\033[0m"
fab init_k8s_system
echo -e "\033[32m{`date`}[结束]初始k8s系统镜像服务.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]初始化测试微服务.............................\033[0m"
fab init_web_test
echo -e "\033[32m{`date`}[结束]初始化测试微服务.............................\n\n\n\n\n\n\033[0m"

echo -e "\033[32m{`date`}[开始]需要您验证测试以下说明.............................\033[0m"
i=0
while true
do
    sleep 1
    ((i++))
    echo -e "\033[32m等待kubernetes-dashboard running($i)s...\033[0m"
    kubectl -n kube-system get pods -o wide | grep kubernetes-dashboard | grep Running
    if [ $? -eq 0 ]; then
        kubectl -n kube-system get pods -o wide | grep kubernetes-dashboard | grep Running | awk '{print "\033[31m您可以访问kubernetes-dashboard: http://"$7":30000\033[0m"}'
        break
    fi
done

i=0
while true
do
    sleep 1
    ((i++))
    echo -e "\033[32m等待monitoring-grafana running($i)s...\033[0m"
    kubectl -n kube-system get pods -o wide | grep monitoring-grafana | grep Running
    if [ $? -eq 0 ]; then
        kubectl -n kube-system get pods -o wide | grep monitoring-grafana | grep Running | awk '{print "\033[31m您可以访问monitoring-grafana: http://"$7":30001\033[0m"}'
        break
    fi
done

i=0
while true
do
    sleep 1
    ((i++))
    echo -e "\033[32m等待web-test running($i)s...\033[0m"
    kubectl -n esn-system get pods -o wide | grep web-test | grep Running
    if [ $? -eq 0 ]; then
        kubectl -n esn-system get pods -o wide | grep web-test | grep Running | awk '{print "\033[31m您可以访问web-test: http://"$7":31000\033[0m";print "\033[31m您可以执行: ssh -i ssh/root/id_rsa root@"$6" 直接登录到容器中\033[0m";print "\033[31m您也可以执行: ssh -i ssh/esn/id_rsa esn@"$6" 直接登录到容器中\033[0m"}'
        break
    fi
done
echo -e "\033[31m您可以进入到容器中执行: ping t.test.com 看是否解析到10.10.10.10上, 或看下面测试输出\033[0m"
POD=`kubectl -n esn-system get pods | grep web-test | awk '{print $1}'`
kubectl -n esn-system exec $POD -- ping -c 5 t.test.com
echo -e "\033[32m{`date`}[结束]需要您验证测试以下说明\033[0m\033[31m[祝您好运，安全稳定的k8s集群安装完毕！]\033[0m\033[32m.............................\n\n\n\n\n\n\033[0m"
