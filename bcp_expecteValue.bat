@Echo off
SET importFile=%1
Echo "parsing file =>%ImportFile%"
bcp.exe "D0146_00_ModelResultaten.staging.ModelData" IN %ImportFile% -S inbo-sql05-dev.inbodev.be  -T -t ; -q -f "Format_ModelData.xml" -F 2 -a 65535 -h TABLOCK
