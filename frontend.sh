#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
NGINX="/etc/nginx/nginx.conf"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi


mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

if [ -f $NGINX ]; then
   echo -e "$Y Existing nginx config found. Removing... $N" | tee -a $LOGS_FILE
  rm -rf "$NGINX" &>>$LOGS_FILE
  VALIDATE $? "Remove existing nginx config"
fi

dnf module list nginx &>>$LOGS_FILE
VALIDATE $? "NodeJs module list" 

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "Disable nginx modules"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "start nginx module 20"

systemctl enable nginx &>>$LOGS_FILE
systemctl start nginx  &>>$LOGS_FILE
VALIDATE $? "Enable & Start Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove HTML default page"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Download frontend content"

cd /usr/share/nginx/html  &>>$LOGS_FILE
unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Extract the files from tmp to default page"


cp /home/ec2-user/robo-shop/nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Copying the nginx.conf"

systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "restart Nginx"

