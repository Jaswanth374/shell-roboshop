#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf module list nginx &>>$LOGS_FILE
VALIDATE $? "NodeJs module list" 

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "Disable nginx modules"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Enable and start nginx module 20"

systemctl enable nginx &>>$LOGS_FILE
systemctl start nginx  &>>$LOGS_FILE
VALIDATE $? "Enable & Start Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove HTML default page"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Download frontend content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "Extract the files from tmp to default page"

cp nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying the nginx.conf"

systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "restart Nginx"

