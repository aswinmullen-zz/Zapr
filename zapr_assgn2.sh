#!/bin/bash
aws ec2 describe-instances --query 'Reservations[].Instances[][State.Name, Tags[?Key==`Name`].Value | [0] , InstanceId]' --output text | grep running |awk {'print $3'} > imageid.txt
aws ec2 describe-instances --query 'Reservations[].Instances[][State.Name, Tags[?Key==`Name`].Value | [0] , InstanceId]' --output text | grep running |awk {'print $2,d}' d="$(date +%d%b)" > tags.txt

##AMI Creation ##
count="$(cat tags.txt | wc -l)"
for((i=1; i<=count; i++))
	do
        aws ec2 create-image --instance-id "`sed -n "$i"p imageid.txt`" --name  "`sed -n "$i"p tags.txt`"   --description "Zapr Instance Image backup" --no-reboot
        done

##AMI DeRegistry ##
d=$(date +%Y-%m-%d --date '7 days ago')
aws ec2 describe-images --owners self  --query 'Images[].{ID:ImageId , Type:Description , Date:CreationDate<=`$d`}'  --output text | grep "Zapr Instance Image backup" | grep "True" | awk {'print $2'}  > amidel_list.txt

for i in `cat amidel_list.txt`;
do
	aws ec2 deregister-image --image-id  $i ;
done
