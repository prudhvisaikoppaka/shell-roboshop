#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
Y="\e[32m"
G="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then
   echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
   exit 1
else
   echo -e "$Y You are running this script with root access $N" | tee -a $LOG_FILE
fi

VALIDATE(){
   if [ $1 -eq 0 ]
    then
      echo -e "$2 is ... $G Success $N" | tee -a $LOG_FILE
    else
      echo -e "$2 is ... $R Failure $N" | tee -a $LOG_FILE
      exit 1
   fi    
}

dnf install maven -y
VALIDATE $? "Installing maven server"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating roboshop system user"

mkdir /app
VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "Downloading shipping user"

cd /app 
unzip /tmp/shipping.zip
VALIDATE $? "Unziping user"

mvn clean package
VALIDATE $? "Installing the clean package"

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "Building the application"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying the shipping.service"

systemctl daemon-reload
VALIDATE $? "System reload"

systemctl enable shipping
VALIDATE $? "Enabling shipping"

systemctl start shipping
VALIDATE $? "Starting shipping"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "Script executation completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE  