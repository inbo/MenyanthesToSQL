install.packages("R.matlab")
install.packages("DBI")


library(R.matlab)
library(DBI)
library(jsonlite)

MenFIlePath <- c("C:/Users/jo_admin/Documents/GitHub/db-scripts-en-queries/Databases/D0146_ModelResultaten/TestImports/R_MenFile/Watina_voorbeeld_werkbaar.men")


############################################################
ExportToSQL <- function(Conn, ListObject, FullPath, PartName){
  # clear staging 
  SQLClear <- paste("DELETE t FROM [staging].[MenFileImport] t WHERE t.PartName= LTRIM(RTRIM('", PartName, "')) AND t.FileFullPath= LTRIM(RTRIM('", FullPath, "'));", collapse="")
  dbExecute(SQLconn,SQLClear)
  
  # Convert to json object ( structured list)
  JsonObject <- toJSON(ListObject[PartName])
  
  # some running vars 
  jsonlength <- nchar(JsonObject) # to the end
  increment <- 0                  # from the start
  Delta <- 3000                   # increment value, nbr of chars to move
  
  # Getting to work, moving json to db in parts
  while (increment < jsonlength){
    DeltaString <- toString("")
    DeltaString <- gsub("\'", "\'\'", substr(JsonObject,increment, increment + Delta))
    
    SQLExec <- paste("INSERT [staging].[MenFileImport] ( FileFullPath, PartName, DeltaNr, DeltaJson )",
                     " SELECT LTRIM(RTRIM('", FullPath, "')), LTRIM(RTRIM('", PartName, "')), ", increment, ", LTRIM(RTRIM('", DeltaString , "'))" ,
                     collapse = "")
    increment <- increment + Delta + 1
    dbExecute(SQLconn,SQLExec)
  }
  #write_json(JsonObject, paste( FullPath,"_", PartName, ".json", collapse=""), useBytes=TRUE)
  
  # Merging large parts back together
  SQLMerge <- paste(" EXEC [dbo].[MenFiles_Parse] @FileFullPath = '", FullPath, "', @PartName = '", PartName, "'", collapse="")
  #print(SQLMerge)
  data <- dbExecute(SQLconn, SQLMerge)
  
  #CLearing house
  dbExecute(SQLconn,SQLClear)
}
############################################################



############################################################
# Metadata Model
# MeetpuntID int not null 
# ModelName nvarchar (100)
# ContactPerPersoon nvarchar (100)
# doel nvarchar(4000)
# paramaters nvarchar(4000)
# IsInclusiveModel 
FileName <- basename(MenFIlePath)
FullPath <- MenFIlePath

############################################################

# build connection to DB
SQLconn <- DBI::dbConnect(odbc::odbc(), 
                          driver="sQL Server",
                          server="inbo-sql05-dev.inbodev.be",
                          port=1433,
                          database="D0146_00_ModelResultaten",
                          trusted_connection="Yes")

# reading  men file into R list-sublist structure
ContentMatFile <- readMat(FullPath)

# getting all named parts of the men file into DB
ExportToSQL (SQLconn, ContentMatFile, FullPath, "M")   #1
ExportToSQL (SQLconn, ContentMatFile, FullPath, "H")   #2
ExportToSQL (SQLconn, ContentMatFile, FullPath, "IN")  #3
ExportToSQL (SQLconn, ContentMatFile, FullPath, "B")   #4
ExportToSQL (SQLconn, ContentMatFile, FullPath, "T")   #5
ExportToSQL (SQLconn, ContentMatFile, FullPath, "ID")  #6
ExportToSQL (SQLconn, ContentMatFile, FullPath, "PS")  #7
ExportToSQL (SQLconn, ContentMatFile, FullPath, "VER") #8

# part 9 is not named, so left behind

# Carve MEn file up into datasets for calculation
SQLMerge <- paste(" EXEC [dbo].[MenLoad] @FileFullPath = '", FullPath, "'", collapse="")
#print(SQLMerge)



data <- dbExecute(SQLconn, SQLMerge)

#Close connection to DB
DBI::dbDisconnect(SQLconn)
