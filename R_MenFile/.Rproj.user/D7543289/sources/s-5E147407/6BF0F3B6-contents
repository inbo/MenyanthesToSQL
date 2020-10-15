# install.packages("Rmatio")
# install.packages("xml2")
# install.packages("htmltools")
# install.packages("rlist")
# install.packages("stringr")
# install.packages("DBI")
# install.packages("odbc")
# install.packages("tidyverse")
install.packages("R.matlab")


library(stringr)
library(rlist)
library(rmatio)
library(xml2)
#library(htmltools)
#library(magrittr)
library(jsonlite)
library(DBI)
library(glue)
library(tidyverse)
library(R.matlab)

##' Convert List to XML
##'
##' Can convert list or other object to an xml object using xmlNode
##' @title List to XML
##' @param item 
##' @param tag xml tag
##' @return xmlNode
##' @export
##' @author David LeBauer, Carl Davidson, Rob Kooper, julien colomb
listToXml <- function(item, tag) {
  # just a textnode, or empty node with attributes
  if(typeof(item) != 'list') {
    if (length(item) > 1) {
      xml <- xmlNode(tag)
      for (name in names(item)) {
        xmlAttrs(xml)[[name]] <- item[[name]]
      }
      return(xml)
    } else {
      return(xmlNode(tag, item))
    }
  }
  
  # create the node
  if (identical(names(item), c("text", ".attrs"))) {
    # special case a node with text and attributes
    xml <- xmlNode(tag, item[['text']])
  } else {
    # node with child nodes
    xml <- xmlNode(tag)
    for(i in 1:length(item)) {
      if (length (item[[i]]) == 0) {}
      else if (names(item)[i] != ".attrs") {
        print(i)
        if (is.null (names(item[[i]][1])) ){
          print(i)
          for (j in c(1:length (item[[i]]))){
            child <- xmlNode(names(item)[i])
            xmlValue(child) <- str_remove(item[[i]][j],"list(")
            print(xmlValue)
            print(toString(child))
            xml <- append.xmlNode(xml,child)
            
          }
        } else {
          xml <- append.xmlNode(xml, listToXml(item[[i]], names(item)[i]))
        }
        
      }
    }    
  }
  
  # add attributes to node
  attrs <- item[['.attrs']]
  for (name in names(attrs)) {
    xmlAttrs(xml)[[name]] <- attrs[[name]]
  }
  return(xml)
}


ExportToSQL <- function(Conn, JsonObject, FullPath, ListPart){
  
  JsonM <-toJSON(ListPart)
  
  jsonlength <- nchar(JsonObject)
  increment <- 0
  Delta <- 3000
  
  while (increment < jsonlength){
    DeltaString <- toString("")
    DeltaString <- substr(JsonObject,increment, increment + Delta)

    SQLExec <- paste("INSERT staging.MenFileImport ( FileFullPath, PartName, DeltaNr, DeltaJson )",
                     " SELECT LTRIM(RTRIM('", FullPath, "')),", "'", Part, "'", ", ", increment, ",LTRIM(RTRIM('", DeltaString , "')) )" ,
                     collapse = "")
    
    increment <- increment + Delta
    dbExecute(SQLconn,SQLExec)
  }
  
}




MenFIlePath <- c("C:/Users/jo_admin/Documents/GitHub/db-scripts-en-queries/Databases/D0146_ModelResultaten/TestImports/R_MenFile/Watina_voorbeeld_werkbaar.men")

ContentMatFile <- read.mat(filename=MenFIlePath)

# ContentMatFile
ContentMatFile

#xmlMatFile <- ContentMatFile


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
# JsonAll <-toJSON (ContentMatFile)
# write_json(JsonAll, "ZZZJson.json", useBytes=TRUE)

JsonVersion <-toJSON (ContentMatFile["VER"])
write_json(JsonVersion, "ZZZJson.json", useBytes=TRUE)

JsonM <-toJSON(ContentMatFile["M"])
ExportToSQL(SQLconn, FullPath, "M" )

# build connection to DB
SQLconn <- DBI::dbConnect(odbc::odbc(), 
                     driver="sQL Server",
                     server="inbo-sql05-dev.inbodev.be",
                     port=1433,
                     database="D0146_00_ModelResultaten",
                     trusted_connection="Yes")

jsonstring <- JsonVersion
jsonlength <- nchar(JsonVersion)
increment <- 0
Delta <- 3000

while (increment < jsonlength){
  DeltaString <- toString("")
  DeltaString <- substr(jsonstring,increment, increment + Delta)
  
  
  SQLExec <- paste("INSERT staging.MenFileImport ( FileFullPath, PartName, DeltaNr, DeltaJson )",
                  " SELECT LTRIM(RTRIM('", FullPath, "')),", "'VER'", ", ", increment, ",LTRIM(RTRIM('", DeltaString , "')) " ,
                  collapse = "")
  
  increment <- increment + Delta
  
  dbExecute(SQLconn,SQLExec)

}


ExportToSQL (Conn, JsonObject, FullPath, ListPart


DBI::dbDisconnect(SQLconn)

