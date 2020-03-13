#! /bin/bash

## FIXME Set me:
PHONE=''
PASSWORD=''
EMAIL=""

BEG_CUR_MONTH=`date +%Y-%m-01`
BEG_PREV_MONTH=`date --date="-1 month" +%Y-%m-01`
BEG_PREV_MONTH_SER=`date --date=$BEG_PREV_MONTH +"%m%%2F%d%%2F%Y"`
END_PREV_MONTH=`date --date="$BEG_CUR_MONTH - 1 day" +%Y-%m-%d`
END_PREV_MONTH_SER=`date --date=$END_PREV_MONTH +"%m%%2F%d%%2F%Y"`

echo Getting bill for period $BEG_PREV_MONTH to $END_PREV_MONTH

PRETTY_MONTH=`date --date="$BEG_PREV_MONTH" +"%m-%Y"`

cookies=`mktemp`
directory=`mktemp -d`
session_id=`curl -s --cookie-jar $cookies https://www.paygonline.com/websc/logon.html  | grep data-page-url= | sed -E 's/[^"]*"([^"]*)".*/\1/'`
curl -s -c $cookies -b $cookies "https://www.paygonline.com/websc/$session_id" -H 'Referer: https://www.paygonline.com/websc/loginPage.html'  --data "phoneNumber=$PHONE&password=$PASSWORD" >/dev/null
curl -s -c $cookies -b $cookies 'https://www.paygonline.com/websc/history.html' > /dev/null
curl -s -c $cookies -b $cookies --output $directory/att_bill_$PRETTY_MONTH.pdf 'https://www.paygonline.com/websc/historyrequest.html' -H 'Origin: https://www.paygonline.com' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: https://www.paygonline.com/websc/history.html' -H 'Connection: keep-alive' --data "pdfAction=true&datefrom=$BEG_PREV_MONTH_SER&dateto=$END_PREV_MONTH_SER&historyTypeCode=CREDIT_DEBIT_E_CHECK" > /dev/null
rm -v $cookies
mutt -a $directory/att_bill_$PRETTY_MONTH.pdf -s "ATT Bill for $PRETTY_MONTH" -- $EMAIL < /dev/null
rm -rf $directory
