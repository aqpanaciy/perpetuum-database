#!/bin/bash

# Wait 60 seconds for SQL Server to start up by ensuring that 
# calling SQLCMD does not return an error code, which will ensure that sqlcmd is accessible
# and that system and user databases return "0" which means all databases are in an "online" state
# https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-ver16 
DBSTATUS=1
ERRCODE=1
i=0

while [[ (($DBSTATUS -ne 0) || ($ERRCODE -ne 0)) && ($i -lt 60) ]]; do
    i=$((i+1))
    echo "Check mssql status. Attempt "$i
    DBSTATUS=$(/opt/mssql-tools18/bin/sqlcmd -C -h -1 -t 1 -U sa -P $MSSQL_SA_PASSWORD -Q "SET NOCOUNT ON; Select SUM(state) from sys.databases")
    ERRCODE=$?
    sleep 1
done

if [[ ($DBSTATUS -ne 0) || ($ERRCODE -ne 0) ]]; then 
    echo "SQL Server took more than 60 seconds to start up or one or more databases are not in an ONLINE state"
    exit 1
fi

echo "Check perpetuumsa DB status."
/opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $MSSQL_SA_PASSWORD -d perpetuumsa
ERRCODE=$?

if [[ $ERRCODE -ne 0 ]]; then 
    echo "Run the setup script to create the DB perpetuumsa."
    /usr/config/sqlpackage /Action:Publish /SourceFile:"perpetuumsa+data.dacpac" /TargetConnectionString:"Server=localhost;Initial Catalog=perpetuumsa;User ID=SA;Password='$MSSQL_SA_PASSWORD';Encrypt=False;Connection Timeout=30;"
fi
