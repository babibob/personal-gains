if
    [ $(date -d $(mdatp health --field product_expiration | tr -d '','' | awk ''{print $2 $1 $3}'') +%s) -ge $(date +%s) ];
then
    echo Expiration date $(mdatp health --field product_expiration);
    echo $(( ($(date -d $(mdatp health --field product_expiration | tr -d '','' | awk ''{print $2 $1 $3}'') +%s) - $(date +%s))/86400 )) days to update;
else
    yum update mdatp -y; mdatp connectivity test; mdatp health;
fi