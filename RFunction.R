library('move')
library('zip')

rFunction <- function(data)
{
  Sys.setenv(tz="UTC")
  
  data.spdf <- SpatialPointsDataFrame(coordinates(data),as.data.frame(data), proj4string=CRS("+proj=longlat +ellps=WGS84 +no_defs"))
  
  targetDirZipFile <- Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp")
  
  targetDirShapeFiles <- paste0(targetDirZipFile,"/moveapps-shapefile")
  dir.create(targetDirShapeFiles)
  
  writeOGR(data.spdf,dsn=targetDirShapeFiles,layer="data",driver="ESRI Shapefile",overwrite_layer=TRUE) 
  
  zip::zip(
    zipfile=paste0(targetDirZipFile,"/data_shps.zip"),
    files=  targetDirShapeFiles,
    root = targetDirZipFile,
    mode = "cherry-pick"
  )

  result <- data
  return(result)
}

  
  
  
  
  
  
  
  
  
  
