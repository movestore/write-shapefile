library('move')
library('zip')

rFunction <- function(data)
{
  Sys.setenv(tz="UTC")
  
  data.spdf <- SpatialPointsDataFrame(coordinates(data),as.data.frame(data), proj4string=CRS("+proj=longlat +ellps=WGS84 +no_defs"))
  
  writeOGR(data.spdf,dsn=Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),layer="data",driver="ESRI Shapefile") 
  #writeOGR(data.spdf,dsn="shapefile_output",layer="data",driver="ESRI Shapefile",overwrite_layer=TRUE)
  
  #zip(zipfile="data_shps.zip",files=paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"data.*"))
  #zip(zipfile="data_shps.zip",files=Sys.glob("shapefile_output/data.*"))
    
  result <- data
  return(result)
}

  
  
  
  
  
  
  
  
  
  
