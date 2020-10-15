install.packages("rlist")
library(rlist)
library(XML)

x <- list(p1 = list(type='A',score=list(c1=10,c2=8)),
          p2 = list(type='B',score=list(c1=9,c2=9)),
          p3 = list(type='B',score=list(c1=9,c2=7)))



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
            xmlValue(child) <- item[[i]][j]
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


xmldoc <- listToXml (x,'root')


