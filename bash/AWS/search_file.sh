FILE_NAME=$1
for bucket in $(aws s3 ls s3:// | awk '{print $3}') ; do echo $bucket ; aws s3 ls s3://$bucket --recursive | grep $FILE_NAME ; done
