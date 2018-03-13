#! /bin/bash

## FIXME Set me:
PHONE=''
PASSWORD=''
EMAIL=""


DATE_NOW=`date +"%m%%2F%d%%2F%Y"`
BEGINNING_MONTH=`date +"%m%%2F01%%2F%Y"`
PRETTY_MONTH=`date +"%m-%Y"`

cookies=`mktemp`
directory=`mktemp -d`
session_id=`curl -s --cookie-jar $cookies https://www.paygonline.com/websc/logon.html  | grep data-page-url= | sed -E 's/[^"]*"([^"]*)".*/\1/'`
curl -s -c $cookies -b $cookies "https://www.paygonline.com/websc/$session_id" -H 'Referer: https://www.paygonline.com/websc/loginPage.html'  --data "phoneNumber=$PHONE&password=$PASSWORD" >/dev/null
curl -s -c $cookies -b $cookies 'https://www.paygonline.com/websc/history.html' > /dev/null
curl -s -c $cookies -b $cookies --output $directory/att_bill_$PRETTY_MONTH.pdf 'https://www.paygonline.com/websc/historyrequest.html' -H 'Origin: https://www.paygonline.com' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: https://www.paygonline.com/websc/history.html' -H 'Connection: keep-alive' --data "pdfAction=true&datefrom=$BEGINNING_MONTH&dateto=$DATE_NOW&historyTypeCode=CREDIT_DEBIT_E_CHECK" > /dev/null
rm -v $cookies
mutt -a $directory/att_bill_$PRETTY_MONTH.pdf -s "ATT Bill for $PRETTY_MONTH" -- $EMAIL < /dev/null
rm -rf $directory
