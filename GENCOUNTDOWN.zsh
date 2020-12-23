#! /bin/zsh
#    Copyright (c) 2011, 2014 nerdopolis (or n3rdopolis) <bluescreen_avenger AT verzion DOT net>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

zmodload zsh/datetime

DECIMALPLACES=4
STARTDATE=$(kdialog --calendar "Enter Start Date")
STARTHOUR=$(kdialog --default "0 = 12AM" --combobox "Enter Start Hour" "0 = 12AM" "1 = 1AM" "2 = 2PM" "3 = 3AM" "4 = 4AM" "5 = 5AM" "6 = 6AM"  "7 = 7AM" "8 = 8AM" "9 = 9AM" "10 = 10AM" "11 = 11AM" "12 = 12PM" "13 = 1PM" "14 = 2PM" "15 = 3PM" "16 = 4PM" "17 = 5PM" "18 = 6PM" "19 = 7PM" "20 = 8PM" "21 = 9PM" "22 = 10PM" "23 = 11PM" | awk '{print $1}')
STARTMINUTE=$(kdialog --default 00 --combobox "Enter Start Minute" 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59)
STARTSECOND=$(kdialog --default 00 --combobox "Enter Start Second" 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59)
#STARTTIMEZONE=$(kdialog --default " " --combobox "Enter Start Timezone (blank for local/optional) You can use http://wwp.greenwichmeantime.com/ to find a location's offest" " " "GMT-12" "GMT-11" "GMT-10" "GMT-9:30" "GMT-9" "GMT-8" "GMT-7" "GMT-6" "GMT-5" "GMT-4:30" "GMT-4" "GMT-3:30" "GMT-3" "GMT-2" "GMT-1" "GMT-0" "GMT+0" "GMT+1" "GMT+2" "GMT+3" "GMT+3:30" "GMT+4" "GMT+4:30" "GMT+5" "GMT+5:30" "GMT+5:45" "GMT+6" "GMT+6:30" "GMT+7" "GMT+8" "GMT+8:45" "GMT+9" "GMT+9:30" "GMT+10" "GMT+10:30" "GMT+11" "GMT+11:30" "GMT+12" "GMT+12:45" "GMT+13" "GMT+14" )
ENDDATE=$(kdialog --calendar "Enter End Date")
ENDHOUR=$(kdialog --default "0 = 12AM" --combobox "Enter End Hour" "0 = 12AM" "1 = 1AM" "2 = 2PM" "3 = 3AM" "4 = 4AM" "5 = 5AM" "6 = 6AM"  "7 = 7AM" "8 = 8AM" "9 = 9AM" "10 = 10AM" "11 = 11AM" "12 = 12PM" "13 = 1PM" "14 = 2PM" "15 = 3PM" "16 = 4PM" "17 = 5PM" "18 = 6PM" "19 = 7PM" "20 = 8PM" "21 = 9PM" "22 = 10PM" "23 = 11PM" | awk '{print $1}')
ENDMINUTE=$(kdialog --default 00 --combobox "Enter End Minute" 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59)
ENDSECOND=$(kdialog  --default 00 --combobox "Enter End Second" 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59)
#ENDTIMEZONE=$(kdialog --default " " --combobox "Enter Start Timezone (blank for local/optional) You can use http://wwp.greenwichmeantime.com/ to find a location's offest" " " "GMT-12" "GMT-11" "GMT-10" "GMT-9:30" "GMT-9" "GMT-8" "GMT-7" "GMT-6" "GMT-5" "GMT-4:30" "GMT-4" "GMT-3:30" "GMT-3" "GMT-2" "GMT-1" "GMT-0" "GMT+0" "GMT+1" "GMT+2" "GMT+3" "GMT+3:30" "GMT+4" "GMT+4:30" "GMT+5" "GMT+5:30" "GMT+5:45" "GMT+6" "GMT+6:30" "GMT+7" "GMT+8" "GMT+8:45" "GMT+9" "GMT+9:30" "GMT+10" "GMT+10:30" "GMT+11" "GMT+11:30" "GMT+12" "GMT+12:45" "GMT+13" "GMT+14" )
COUNTDOWNMESSAGE=$(kdialog --textinputbox "Enter Custom Message (optional)")


START=$(date -d "$STARTDATE $STARTTIMEZONE $STARTHOUR:$STARTMINUTE:$STARTSECOND" +"%s")
END=$(date -d "$ENDDATE $ENDTIMEZONE $ENDHOUR:$ENDMINUTE:$ENDSECOND" +"%s")

str_STARTDATE=$(date -d @$START +"%Y-%m-%d %H:%M:%S %z")
str_ENDDATE=$(date -d @$END +"%Y-%m-%d %H:%M:%S %z")

NOW=$(date +"%s")
RANGE=$((END-START))

if [ $RANGE -le 0 ]
then
kdialog --sorry "End date is before or the same as the start date

$STARTDATE $STARTTIMEZONE $STARTHOUR:$STARTMINUTE:$STARTSECOND to $ENDDATE $ENDTIMEZONE $ENDHOUR:$ENDMINUTE:$ENDSECOND"
exit
fi


IFS=" "
dcopRef=($(kdialog  --icon ktimer --progressbar "Countdown")) 
unset IFS

SECONDS_LEFT=$((END-NOW))
SECONDS_PASSED=$((RANGE-SECONDS_LEFT))
PASSED_PERCENT=$(( SECONDS_PASSED*1.0 * 100 / RANGE ))
LEFT_PERCENT=$(( 100 -(SECONDS_PASSED*1.0 * 100 / RANGE) ))


if [[ $PASSED_PERCENT -gt 100 ]]
then
kdialog --msgbox "End date is in the past

$STARTDATE $STARTTIMEZONE $STARTHOUR:$STARTMINUTE:$STARTSECOND to $ENDDATE $ENDTIMEZONE $ENDHOUR:$ENDMINUTE:$ENDSECOND
" &
qdbus ${dcopRef[1]} ${dcopRef[2]} org.freedesktop.DBus.Properties.Set org.kde.kdialog.ProgressDialog value 0  > /dev/null 2>&1
fi
if [[ $PASSED_PERCENT -lt 0 ]]
then
kdialog --msgbox "Start date is in the future
$STARTDATE $STARTTIMEZONE $STARTHOUR:$STARTMINUTE:$STARTSECOND to $ENDDATE $ENDTIMEZONE $ENDHOUR:$ENDMINUTE:$ENDSECOND
" &
qdbus ${dcopRef[1]} ${dcopRef[2]} org.freedesktop.DBus.Properties.Set org.kde.kdialog.ProgressDialog value 100  >  /dev/null 2>&1
fi

completed=0 



RANGE=$((END-START))
RANGE_TOTAL_MINUTES=$(( RANGE*1.0/60 ))
RANGE_TOTAL_HOURS=$(( RANGE_TOTAL_MINUTES*1.0/60 ))
RANGE_TOTAL_DAYS=$(( RANGE_TOTAL_HOURS*1.0/24 ))
RANGE_TOTAL_WEEKS=$(( RANGE_TOTAL_DAYS*1.0/7 ))
RANGE_TOTAL_MONTHS=$(( RANGE_TOTAL_DAYS*1.0/30 ))
RANGE_TOTAL_YEARS=$(( RANGE_TOTAL_DAYS*1.0/365.25 ))
  integer RANGE_DAYS=$(( RANGE_TOTAL_DAYS/1 ))
  integer RANGE_HOURS=$(( ((RANGE_TOTAL_HOURS-(RANGE_DAYS*24))%24) /1 ))
  integer RANGE_MINUTES=$(( (RANGE_TOTAL_MINUTES-(RANGE_HOURS*60)-(RANGE_DAYS*60*24)) /1 ))
  integer RANGE_SECONDS=$(( (RANGE-(RANGE_MINUTES*60)-(RANGE_HOURS*60*60)-(RANGE_DAYS*60*24*60))/1 ))

ONEPERCENT_RANGE=$((RANGE/100))
ONEPERCENT_RANGE_TOTAL_MINUTES=$(( ONEPERCENT_RANGE*1.0/60 ))
ONEPERCENT_RANGE_TOTAL_HOURS=$(( ONEPERCENT_RANGE_TOTAL_MINUTES*1.0/60 ))
ONEPERCENT_RANGE_TOTAL_DAYS=$(( ONEPERCENT_RANGE_TOTAL_HOURS*1.0/24 ))
ONEPERCENT_RANGE_TOTAL_WEEKS=$(( ONEPERCENT_RANGE_TOTAL_DAYS*1.0/7 ))
ONEPERCENT_RANGE_TOTAL_MONTHS=$(( ONEPERCENT_RANGE_TOTAL_DAYS*1.0/30 ))
ONEPERCENT_RANGE_TOTAL_YEARS=$(( ONEPERCENT_RANGE_TOTAL_DAYS*1.0/365.25 ))
  integer ONEPERCENT_RANGE_DAYS=$(( ONEPERCENT_RANGE_TOTAL_DAYS/1 ))
  integer ONEPERCENT_RANGE_HOURS=$(( ((ONEPERCENT_RANGE_TOTAL_HOURS-(ONEPERCENT_RANGE_DAYS*24))%24) /1 ))
  integer ONEPERCENT_RANGE_MINUTES=$(( (ONEPERCENT_RANGE_TOTAL_MINUTES-(ONEPERCENT_RANGE_HOURS*60)-(ONEPERCENT_RANGE_DAYS*60*24)) /1 ))
  integer ONEPERCENT_RANGE_SECONDS=$(( (ONEPERCENT_RANGE-(ONEPERCENT_RANGE_MINUTES*60)-(ONEPERCENT_RANGE_HOURS*60*60)-(ONEPERCENT_RANGE_DAYS*60*24*60))/1 ))

  
printf -v str_RANGE "%.4f" $RANGE
printf -v str_RANGE_TOTAL_MINUTES "%.4f" $RANGE_TOTAL_MINUTES
printf -v str_RANGE_TOTAL_HOURS "%.4f" $RANGE_TOTAL_HOURS
printf -v str_RANGE_TOTAL_DAYS "%.4f" $RANGE_TOTAL_DAYS
printf -v str_RANGE_TOTAL_WEEKS "%.4f" $RANGE_TOTAL_WEEKS
printf -v str_RANGE_TOTAL_MONTHS "%.4f" $RANGE_TOTAL_MONTHS
printf -v str_RANGE_TOTAL_YEARS "%.4f" $RANGE_TOTAL_YEARS


printf -v str_ONEPERCENT_RANGE "%.4f" $ONEPERCENT_RANGE
printf -v str_ONEPERCENT_RANGE_TOTAL_MINUTES "%.4f" $ONEPERCENT_RANGE_TOTAL_MINUTES
printf -v str_ONEPERCENT_RANGE_TOTAL_HOURS "%.4f" $ONEPERCENT_RANGE_TOTAL_HOURS
printf -v str_ONEPERCENT_RANGE_TOTAL_DAYS "%.4f" $ONEPERCENT_RANGE_TOTAL_DAYS
printf -v str_ONEPERCENT_RANGE_TOTAL_WEEKS "%.4f" $ONEPERCENT_RANGE_TOTAL_WEEKS
printf -v str_ONEPERCENT_RANGE_TOTAL_MONTHS "%.4f" $ONEPERCENT_RANGE_TOTAL_MONTHS
printf -v str_ONEPERCENT_RANGE_TOTAL_YEARS "%.4f" $ONEPERCENT_RANGE_TOTAL_YEARS


while [ 1 ]
do
NOW=$EPOCHSECONDS
CURRENT=$(strftime  "%Y-%m-%d %H:%M:%S %z" $EPOCHSECONDS)

SECONDS_LEFT=$((END-NOW))
SECONDS_PASSED=$((RANGE-SECONDS_LEFT))
PASSED_PERCENT=$(( SECONDS_PASSED*1.0 * 100 / RANGE )) 
ROUND_PERCENT=$(( SECONDS_PASSED * 100 / RANGE ))
LEFT_PERCENT=$(( 100 -(SECONDS_PASSED*1.0 * 100 / RANGE) ))
ROUND_LEFT_PERCENT=$(( 100 -(SECONDS_PASSED * 100 / RANGE) ))

PASSED_TOTAL_MINUTES=$(( SECONDS_PASSED*1.0/60 ))
PASSED_TOTAL_HOURS=$(( PASSED_TOTAL_MINUTES*1.0/60 ))
PASSED_TOTAL_DAYS=$(( PASSED_TOTAL_HOURS*1.0/24 ))
PASSED_TOTAL_WEEKS=$(( PASSED_TOTAL_DAYS*1.0/7 ))
PASSED_TOTAL_MONTHS=$(( PASSED_TOTAL_DAYS*1.0/30 ))
PASSED_TOTAL_YEARS=$(( PASSED_TOTAL_DAYS*1.0/365.25 ))
  integer PASSED_DAYS=$((PASSED_TOTAL_DAYS / 1 ))
  integer PASSED_HOURS=$(( (PASSED_TOTAL_HOURS-(PASSED_DAYS*24))%24 ))
  integer PASSED_MINUTES=$(( (PASSED_TOTAL_MINUTES-(PASSED_HOURS*60)-(PASSED_DAYS*60*24))/1 ))
  integer PASSED_SECONDS=$(( (SECONDS_PASSED-(PASSED_MINUTES*60)-(PASSED_HOURS*60*60)-(PASSED_DAYS*60*24*60))/1 ))

REMAINING_TOTAL_MINUTES=$(( SECONDS_LEFT*1.0/60 ))
REMAINING_TOTAL_HOURS=$(( REMAINING_TOTAL_MINUTES*1.0/60 ))
REMAINING_TOTAL_DAYS=$(( REMAINING_TOTAL_HOURS*1.0/24 ))
REMAINING_TOTAL_WEEKS=$(( REMAINING_TOTAL_DAYS*1.0/7 ))
REMAINING_TOTAL_MONTHS=$(( REMAINING_TOTAL_DAYS*1.0/30 ))
REMAINING_TOTAL_YEARS=$(( REMAINING_TOTAL_DAYS*1.0/365.25 ))
  integer REMAINING_DAYS=$(( REMAINING_TOTAL_DAYS/1 ))
  integer REMAINING_HOURS=$(( ((REMAINING_TOTAL_HOURS-(REMAINING_DAYS*24))%24)/1 ))
  integer REMAINING_MINUTES=$(( (REMAINING_TOTAL_MINUTES-(REMAINING_HOURS*60)-(REMAINING_DAYS*60*24))/1 ))
  integer REMAINING_SECONDS=$(( (SECONDS_LEFT-(REMAINING_MINUTES*60)-(REMAINING_HOURS*60*60)-(REMAINING_DAYS*60*24*60))/1 ))


printf -v str_SECONDS_LEFT "%.4f" $SECONDS_LEFT
printf -v str_SECONDS_PASSED "%.4f" $SECONDS_PASSED

printf -v str_PASSED_PERCENT "%.4f" $PASSED_PERCENT
printf -v str_LEFT_PERCENT "%.4f" $LEFT_PERCENT


printf -v str_PASSED_TOTAL_MINUTES "%.4f" $PASSED_TOTAL_MINUTES
printf -v str_PASSED_TOTAL_HOURS "%.4f" $PASSED_TOTAL_HOURS
printf -v str_PASSED_TOTAL_DAYS "%.4f" $PASSED_TOTAL_DAYS
printf -v str_PASSED_TOTAL_WEEKS "%.4f" $PASSED_TOTAL_WEEKS
printf -v str_PASSED_TOTAL_MONTHS "%.4f" $PASSED_TOTAL_MONTHS
printf -v str_PASSED_TOTAL_YEARS "%.4f" $PASSED_TOTAL_YEARS


printf -v str_REMAINING_TOTAL_MINUTES "%.4f" $REMAINING_TOTAL_MINUTES
printf -v str_REMAINING_TOTAL_HOURS "%.4f" $REMAINING_TOTAL_HOURS
printf -v str_REMAINING_TOTAL_DAYS "%.4f" $REMAINING_TOTAL_DAYS
printf -v str_REMAINING_TOTAL_WEEKS "%.4f" $REMAINING_TOTAL_WEEKS
printf -v str_REMAINING_TOTAL_MONTHS "%.4f" $REMAINING_TOTAL_MONTHS
printf -v str_REMAINING_TOTAL_YEARS "%.4f" $REMAINING_TOTAL_YEARS



printf -v TIMESTRING "%s" "Percent from $str_STARTDATE to $str_ENDDATE

It is currently: $CURRENT

$COUNTDOWNMESSAGE

 $str_PASSED_PERCENT % passed
 $str_LEFT_PERCENT % left

 $str_SECONDS_PASSED seconds passed
     $str_PASSED_TOTAL_MINUTES minutes passed
     $str_PASSED_TOTAL_HOURS hours passed
     $str_PASSED_TOTAL_DAYS days passed
     $str_PASSED_TOTAL_WEEKS weeks passed
     $str_PASSED_TOTAL_MONTHS months passed
     $str_PASSED_TOTAL_YEARS years passed    

$PASSED_DAYS Days, $PASSED_HOURS Hours, $PASSED_MINUTES Minutes, $PASSED_SECONDS Seconds passed.

 $str_SECONDS_LEFT seconds left
     $str_REMAINING_TOTAL_MINUTES minutes left
     $str_REMAINING_TOTAL_HOURS hours left
     $str_REMAINING_TOTAL_DAYS days left
     $str_REMAINING_TOTAL_WEEKS weeks left
     $str_REMAINING_TOTAL_MONTHS months left
     $str_REMAINING_TOTAL_YEARS years left

$REMAINING_DAYS Days, $REMAINING_HOURS Hours, $REMAINING_MINUTES Minutes, $REMAINING_SECONDS Seconds left.

 $str_RANGE seconds in total
     $str_RANGE_TOTAL_MINUTES minutes in total
     $str_RANGE_TOTAL_HOURS hours in total
     $str_RANGE_TOTAL_DAYS days in total
     $str_RANGE_TOTAL_WEEKS weeks in total
     $str_RANGE_TOTAL_MONTHS months in total
     $str_RANGE_TOTAL_YEARS years in total 

$RANGE_DAYS Days, $RANGE_HOURS Hours, $RANGE_MINUTES Minutes, $RANGE_SECONDS Seconds in total.
$ONEPERCENT_RANGE_DAYS Days, $ONEPERCENT_RANGE_HOURS Hours, $ONEPERCENT_RANGE_MINUTES Minutes, $ONEPERCENT_RANGE_SECONDS Seconds in each 1% of the timeframe."


qdbus ${dcopRef[1]} ${dcopRef[2]} org.freedesktop.DBus.Properties.Set org.kde.kdialog.ProgressDialog value $ROUND_PERCENT > /dev/null 2>&1
qdbus ${dcopRef[1]} ${dcopRef[2]} org.kde.kdialog.ProgressDialog.setLabelText "$TIMESTRING"  > /dev/null 2>&1
if [ $? = 1 ]
then
exit
fi

LEFT_PERCENT=$(( 100 -(SECONDS_PASSED*1.0 * 100 / RANGE) ))
if [[  $PASSED_PERCENT -gt 100 && $completed -eq 0 ]] 
then
kdialog --msgbox "End date reached." &
qdbus ${dcopRef[1]} ${dcopRef[2]} org.freedesktop.DBus.Properties.Set org.kde.kdialog.ProgressDialog value 100  > /dev/null 2>&1
completed=1
fi



sleep 1
done
