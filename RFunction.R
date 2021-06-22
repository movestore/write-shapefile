library('move')

rFunction <- function(data)
{
  Sys.setenv(tz="GMT")
  
  data.spdf <- SpatialPointsDataFrame(coordinates(data),as.data.frame(data), proj4string=CRS("+proj=longlat +ellps=WGS84 +no_defs"))
  
  writeOGR(data.spdf,dsn=paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"shapefile_output"),layer="data",driver="ESRI Shapefile") #ask Clemens for path
  
  #writeOGR(data.spdf,dsn="shapefile_output",layer="data",driver="ESRI Shapefile")
  
  result <- data
  return(result)
}

  
  
  
  
  
  
  
  
  
  
