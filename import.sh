#https://gist.github.com/everdaniel/9399844/revisions http://172.16.10.23/whosin2/whosin3/modules/payroll/view_salary_reports.php
#!/bin/bash
WORKDIR="$( cd "$( dirname "$0" )" && pwd )"
DB_USER="blue"
DB_PASSWORD="Kittenmittens1"
DB_NAME="blue"
FILE_PROC="$WORKDIR/processing"
FILE_COMP="$WORKDIR/completed"

cd $WORKDIR

for _csv_file in *.csv; do     
	_csv_file_name=`echo $(basename "$_csv_file")`; 
	_csv_file_name_new=`echo $(basename "$_csv_file") | sed 's/-/_/g'`; 
	mv $_csv_file_name $_csv_file_name_new;
done;

for _csv_file in *.csv; do     
	_csv_file_name=`echo $(basename "$_csv_file")`; 
	_csv_file_extensionless=`echo $(basename "$_csv_file") | sed 's/\(.*\)\..*/\1/'`; 
	_table_name="${_csv_file_extensionless}";
	echo "table name : $_table_name";
	_header_columns=`head -1 $WORKDIR/$_csv_file | tr ',' '\n' | sed 's/^"//' | sed 's/"$//' | sed 's/ #$//' | sed 's/ /_/g' | sed 's/-/_/g'`;
	mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME --execute="DROP TABLE \`$_table_name\`"
	mysql -u $DB_NAME -p$DB_PASSWORD $DB_USER << eof
		CREATE TABLE IF NOT EXISTS \`$_table_name\` (
		  id int(11) NOT NULL auto_increment,
		  PRIMARY KEY  (id)
		) ENGINE=MyISAM DEFAULT CHARSET=latin1
eof
	columnss='';
	for _header in ${_header_columns[@]};
	do 
		mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME --execute="alter table \`$_table_name\` add column \`$_header\` text"
		columnss+="$_header,"
	done;
	finalcolumns=`\`$columnss\` | sed 's/,$//'`;

# if [ -e $FILE_PROC ]
# then
    # clear
    # echo "Files are currently being processed. Run Forrest Run!!!"
    # exit
# fi

# if [ -e $FILE_COMP ]
# then
    # clear
    
    
    
    # Make sure if job runs again to not process these files
    # touch $FILE_PROC

    # echo "--> Cleaning database"
    # mysql -h localhost -u $DB_USER -p$DB_PASSWORD $DB_NAME < $WORKDIR/clear_tt.sql
    # echo "Database cleaned."
    # echo "<-- Done cleaning database"
	echo "==>"
    echo "==> ** IMPORTING BRENTWOOD DATA"
    echo "==>"
    echo "--> Importing tables"
    mysqlimport -h localhost -u $DB_USER -p$DB_PASSWORD --local --delete --fields-terminated-by=',' --fields-enclosed-by='"' --columns=$finalcolumns  --ignore-lines=1 --default-character-set=utf8 $DB_NAME $WORKDIR/$_csv_file_name
    echo "<-- Done importing tables"

    # echo "==>"
    # echo "==> ** IMPORTING GREEN HILLS DATA"
    # echo "==>"
    # echo "--> Importing tables"
    # mysqlimport -h localhost -u $DB_USER -p$DB_PASSWORD --local --delete --fields-terminated-by=',' --fields-enclosed-by='"' --ignore-lines=1 --default-character-set=utf8 $DB_NAME $WORKDIR/Green_tblAltContacts.csv $WORKDIR/Green_tblContacts.csv $WORKDIR/Green_tblEmployees.csv $WORKDIR/Green_tblSchedule.csv $WORKDIR/Green_tblScheduleMultiple.csv $WORKDIR/Green_tblScheduleRepeat.csv $WORKDIR/Green_valTblLocation.csv $WORKDIR/Green_valTblWorkCodes.csv
    # echo "<-- Done importing tables"

    

    
# fi
done;
echo "Deleting files"
    # rm -f $WORKDIR/*.csv
    # rm -f $FILE_PROC
    # rm -f $FILE_COMP
exit
echo "Nothing to process"
