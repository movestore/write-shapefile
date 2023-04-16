library('move')
library('zip')
library('stringr')

rFunction <- function(data,file.name="moveapps-shapefile")
{
  Sys.setenv(tz="UTC")
  
  data.spdf <- SpatialPointsDataFrame(coordinates(data),as.data.frame(data), proj4string=CRS("+proj=longlat +ellps=WGS84 +no_defs"))
  
  dir.create(targetDirZipFile <- Sys.getenv(x = "APP_ARTIFACTS_DIR", "artefact-mock"))
  
  dir.create(targetDirShapeFiles <- tempdir())
  targetDirShapeFiles <- paste0(targetDirShapeFiles,"/",file.name)
  logger.info(paste0("Storing shapefiles in tmp-dir ", targetDirShapeFiles))
  
  # careful, for writeOGR the column names have to be unique in the first 10 characters, that can be problematic and has to be adressed here
  shnames <- read.csv(paste0(getAppFilePath("vocab"), "MovebankVocab_ShapefileNamesF.csv"),header=TRUE) #adapt for local file path!
  shnames$name <- tolower(make.names(shnames$name,allow_=FALSE))
  shnames$shortname_mx10 <- make.names(shnames$shortname_mx10,allow_=FALSE)
  
  nms <- names(data.spdf@data)
  nms <- tolower(make.names(nms,allow_=FALSE))
  shortname_novoc<- apply(matrix(nms),1,function(x) stringr::str_replace_all(x, "[aeiou ]", ""))
  shortname_novoc_max10 <- substring(shortname_novoc,1,10)
  
  for(i in seq(along=names(data.spdf@data)))
  {
    if (nchar(nms[i]) > 10) 
      {
      if (nms[i] %in% shnames$name)
      {
        ix <- which(shnames$name==nms[i])
        nms[i] <- shnames$shortname_mx10[ix[1]]
      } else nms[i] <- shortname_novoc_max10[i]
    }
  }

  #if there are duplicates shorten and index
  X <- 0
  while (any(duplicated(nms)) & (L+X)<100)
  {
    dpl <- which(duplicated(nms)) 
    for (k in seq(along=dpl))
    {
      dd <- which(nms==nms[dpl[k]])
      L <- length(dd)
      nms[dd] <- paste0(substr(nms[dpl[k]],1,8),c(1:L+X))
      X <- X+1
    }
  }
  names(data.spdf@data) <- nms
  
  # fix matrix columns to numeric
  for (j in seq(along=nms))
  {
    if (class(data.spdf@data[,nms[j]])[1]=="matrix")
    {
      data.spdf@data[,nms[j]] <- as.numeric(data.spdf@data[,nms[j]])
      logger.info(paste("Your variable",nms[j],"had to be transferred to numeric."))
    }
  }
  
  writeOGR(data.spdf,dsn=targetDirShapeFiles,layer=file.name,driver="ESRI Shapefile",overwrite_layer=TRUE) 
  #library('rgdal')
  #writeOGR(data,dsn=targetDirShapeFiles,layer="data",driver="ESRI Shapefile",overwrite_layer=TRUE) 
  
  zip::zip(
    zipfile=paste0(targetDirZipFile,"/data_shps.zip"),
    files=  targetDirShapeFiles,
    #root = targetDirZipFile,
    mode = "cherry-pick"
  )

  result <- data
  return(result)
}

  
  
##try with sf  
#library('sf')
#data.sf <- st_as_sf(data)
#st_write(data.sf,"artefact-mock/nc.shp",delete_layer=TRUE)
  
#for (i in seq(along=shnames$shortname_mx10)) #tested if any in list with length >10
#{
#  if (nchar(shnames$shortname_mx10[i])>10) print(i)
#}
  
  
  
  
