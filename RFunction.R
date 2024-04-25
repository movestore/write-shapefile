library('move2')
library('sf')
library('dplyr')
library('zip')
library('stringr')

rFunction = function(data, pts=TRUE, seg=TRUE, lins=TRUE, gpkg=TRUE, file.name="moveapps-shapefile", ...) {
  
  ## move all track associated attributes to the event table
  data_allattrb <- mt_as_event_attribute(data, names(mt_track_data(data)))
  ## drop all attributes that are all NA
  data_allattrb <- data_allattrb %>% select(where(~ !(all(is.na(.)))))
  
  # create folder for storing subfiles to then zip
  dir.create(targetDirZipFile <- Sys.getenv(x = "APP_ARTIFACTS_DIR", "artefact-mock"))
  dir.create(targetDirShapeFiles <- tempdir())
  targetDirShapeFiles <- paste0(targetDirShapeFiles,"/",file.name)
  logger.info(paste0("Storing shapefiles in tmp-dir ", targetDirShapeFiles))
  
  ## update attribute names to max 10 characters. use file from Sarah
  shnames <- read.csv(getAuxiliaryFilePath("vocab"),header=TRUE) #adapted to USER_FILE: "MovebankVocab_ShapefileNamesF.csv"
  shnames$name <- tolower(make.names(shnames$name,allow_=FALSE))
  shnames$shortname_mx10 <- make.names(shnames$shortname_mx10,allow_=FALSE)
  
  nms <- names(data_allattrb)
  nms <- tolower(make.names(nms,allow_=FALSE))
  shortname_novoc<- apply(matrix(nms),1,function(x) stringr::str_replace_all(x, "[aeiou ]", ""))
  shortname_novoc_max10 <- substring(shortname_novoc,1,10)
  
  for(i in seq(along=names(data_allattrb)))
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
  L <- 0
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
  ix_trackid <- which(names(data_allattrb)==mt_track_id_column(data_allattrb))
  mt_track_id(data_allattrb) <- nms[ix_trackid] #NEEDS MORE TESTNG, WHY DID THIS WORK BEFORE? CHECK HELP SITE EXAMPLE AGAIN
  names(data_allattrb) <- nms

  # fix matrix columns to numeric, this might not work with move2, but may also not cause problems
  #for (j in seq(along=nms))
  #{
  #  if (class(data_allattrb[,nms[j]])[1]=="matrix")
  #  {
  #    data_allattrb[,nms[j]] <- as.numeric(data_allattrb[,nms[j]])
  #    logger.info(paste("Your variable",nms[j],"had to be transferred to numeric."))
  #  }
  #}
  
  ## Save as a Shapefile -> Points
  
  if (pts==TRUE)
  {
    logger.info("You have requested a shapefile with all data points. They are zipped into a file called data_points_shps.zip.")
    sf::st_write(data_allattrb, targetDirShapeFiles, layer=file.name, driver="ESRI Shapefile", delete_layer = TRUE)
    zip::zip(
      zipfile=paste0(targetDirZipFile,"/data_points_shps.zip"),
      files=  targetDirShapeFiles,
      #root = targetDirZipFile,
      mode = "cherry-pick"
    )
    if (gpkg==TRUE)
    {
      logger.info("You have requested a gpkg file for the points of the track(s).")
      data_allattrb2 <- mt_as_event_attribute(data, names(mt_track_data(data)))
      data_allattrb2 <- data_allattrb2 %>% select(where(~ !(all(is.na(.)))))
      sf::st_write(data_allattrb2, dsn=paste0(targetDirZipFile,"/",file.name,"_points.gpkg"), driver="GPKG", delete_layer = TRUE) # for overwriting
    }
  }

  ## making lines out of a move2 obj
  ## segments
  # data_segments <- mt_segments(data) # returns lines between consecutive points, ie segments. Contains no attrib except locations, traks cannot be identified. So alternative is:
  
  if (seg==TRUE)
  {
    logger.info("You have requested a shapefile with all track segments. They are zipped into a file called data_segments_shps.zip.")
    data_allattrb_seg <- data_allattrb
    data_allattrb_seg$segments <- mt_segments(data_allattrb_seg)
    data_allattrb_seg <-data_allattrb_seg %>%  dplyr::filter(st_geometry_type(data_allattrb_seg$segments) == "LINESTRING") # as the last one is a point, this has to be removed or it cannot be saved with st_write()
    st_geometry(data_allattrb_seg) <- data_allattrb_seg$segments ## making the segments the geometry of the object
    
    sf::st_write(data_allattrb_seg, targetDirShapeFiles, layer=file.name, driver="ESRI Shapefile", delete_layer = TRUE)
    zip::zip(
      zipfile=paste0(targetDirZipFile,"/data_segments_shps.zip"),
      files=  targetDirShapeFiles,
      #root = targetDirZipFile,
      mode = "cherry-pick"
    )
    if (gpkg==TRUE)
    {
      logger.info("You have requested a gpkg file for the segments of the track(s).")
      data_allattrb2 <- mt_as_event_attribute(data, names(mt_track_data(data)))
      data_allattrb2 <- data_allattrb2 %>% select(where(~ !(all(is.na(.)))))
      
      data_allattrb2_seg <- data_allattrb2
      data_allattrb2_seg$segments <- mt_segments(data_allattrb2_seg)
      data_allattrb2_seg <-data_allattrb2_seg %>%  dplyr::filter(st_geometry_type(data_allattrb2_seg$segments) == "LINESTRING") # as the last one is a point, this has to be removed or it cannot be saved with st_write()
      st_geometry(data_allattrb2_seg) <- data_allattrb2_seg$segments ## making the segments the geometry of the object
      
      sf::st_write(data_allattrb2_seg, dsn=paste0(targetDirZipFile,"/",file.name,"_segments.gpkg"), driver="GPKG", delete_layer = TRUE) # for overwriting
    }
  }

  ## one line per track
  if (lins==TRUE)
  {
    logger.info("You have requested a shapefile with all tracks as lines. They are zipped into a file called data_lines_shps.zip.")
    data_allattrb_lines <- mt_track_lines(data_allattrb) # returns one line per track, track attrb are kept
    
    sf::st_write(data_allattrb_lines, targetDirShapeFiles, layer=file.name, driver="ESRI Shapefile", delete_layer = TRUE)
    zip::zip(
      zipfile=paste0(targetDirZipFile,"/data_lines_shps.zip"),
      files=  targetDirShapeFiles,
      #root = targetDirZipFile,
      mode = "cherry-pick"
    )
    if (gpkg==TRUE)
    {
      logger.info("You have requested a gpkg file for the line(s) of the track(s).")
      data_allattrb2 <- mt_as_event_attribute(data, names(mt_track_data(data)))
      data_allattrb2 <- data_allattrb2 %>% select(where(~ !(all(is.na(.)))))
      
      data_allattrb2_lines <- mt_track_lines(data_allattrb2) # returns one line per track, track attrb are kept
      
      sf::st_write(data_allattrb2_lines, dsn=paste0(targetDirZipFile,"/",file.name,"_lines.gpkg"), driver="GPKG", delete_layer = TRUE) # for overwriting
    }
  }

  return(data)
}
