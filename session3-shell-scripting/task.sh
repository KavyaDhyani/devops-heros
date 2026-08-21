#!/bin/bash

# print current date
# hostname and username
# process
# add process info inside a file name process.log

# print name,roll_no, comment 

## use variables, take input, create file and directory

curr_date=$(date)
hostname=$(hostname)
username=$(whoami)

read -p "Enter your name: " name
read -p "Enter your roll number: " rollNumber
read -p "Enter your comment: " comment

mkdir process_info
cd process_info
echo "$(ps -ef)" > process.log

echo "current date: $curr_date"
echo "hostname: $hostname"
echo "username: $username"

df -h

echo "Name: $name"
echo "Roll Number: $rollNumber"
echo "Comment: $comment"

cat process.log

