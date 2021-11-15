library('move')
library('zip')

rFunction <- function(data)
{
  Sys.setenv(tz="UTC")
  
  data.spdf <- SpatialPointsDataFrame(coordinates(data),as.data.frame(data), proj4string=CRS("+proj=longlat +ellps=WGS84 +no_defs"))
  
  dir.create(targetDirZipFile <- Sys.getenv(x = "APP_ARTIFACTS_DIR", "artefact-mock"))
  
  dir.create(targetDirShapeFiles <- tempdir())
  targetDirShapeFiles <- paste0(targetDirShapeFiles,"/moveapps-shapefile")
  logger.info(paste0("Storing shapefiles in tmp-dir ", targetDirShapeFiles))
  
  # careful, for writeOGR the column names have to be unique in the first 10 characters, that can be problematic and has to be adressed here
  for(i in seq(along=names(data.spdf@data)))
  {
    if(nchar(names(data.spdf@data)[i]) > 10) names(data.spdf@data)[i] <- substring(names(data.spdf@data)[i],1,9)
  }
  ix9 <- which(nchar(names(data.spdf@data))==9)
  multi <- names(table(names(data.spdf@data)[ix9]))[table(names(data.spdf@data)[ix9])>1]
  for (j in seq(along=multi))
  {
    ixmj <- which(names(data.spdf@data)==multi[j])
    names(data.spdf@data)[ixmj] <- paste0(names(data.spdf@data)[ixmj],1:length(ixmj))
  }
  writeOGR(data.spdf,dsn=targetDirShapeFiles,layer="data",driver="ESRI Shapefile",overwrite_layer=TRUE) 
  
  zip::zip(
    zipfile=paste0(targetDirZipFile,"/data_shps.zip"),
    files=  targetDirShapeFiles,
    #root = targetDirZipFile,
    mode = "cherry-pick"
  )

  result <- data
  return(result)
}

  
  
  
  
  
  
  
  
  
  
