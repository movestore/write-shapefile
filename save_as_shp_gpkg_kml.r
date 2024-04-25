library(move2)
library(sf)
library(dplyr)

srk <- movebank_download_study(study_id = 21231406, individual_local_identifier=c("Angela / DER AY470 (eobs 4001)","Europa / DER A1A26 (eobs 4004)"),timestamp_start="20240101000000000")
srk <- dplyr::filter(srk, !sf::st_is_empty(srk)) 

## app code would start here

## move all track associated attributes to the event table
srk_allattrb <- mt_as_event_attribute(srk, names(mt_track_data(srk)))
## drop all attributes that are all NA
srk_allattrb <- srk_allattrb %>% select(where(~ !(all(is.na(.)))))

## making lines out of a move2 obj
## segments
# srk_segments <- mt_segments(srk) # returns lines between consecutive points, ie segments. Contains no attrib except locations, traks cannot be identified. So alternative is:
srk_allattrb_seg <- srk_allattrb
srk_allattrb_seg$segments <- mt_segments(srk_allattrb_seg)
srk_allattrb_seg <-srk_allattrb_seg %>%  dplyr::filter(st_geometry_type(srk_allattrb_seg$segments) == "LINESTRING") # as the last one is a point, this has to be removed or it cannot be saved with st_write()
st_geometry(srk_allattrb_seg) <- srk_allattrb_seg$segments ## making the segments the geometry of the object

## one line per track
srk_lines <- mt_track_lines(srk) # returns one line per track, track attrb are kept


## Save as a Shapefile -> Points
sf::st_write(srk_allattrb, "/home/ascharf/Downloads/testshp", layer="stork_pts", driver="ESRI Shapefile", delete_layer = TRUE) # for overwriting
## gives error because 2 attrb are abbreviated to the same: 
## "sensor_type_id"&"sensor_type_ids" -> `sensr_typ_d'
## I tried several several solutions:
# 1. just select the most basic attributes, eg:
srk_sub <- select(srk, mt_time_column(srk), geometry, mt_track_id_column(srk))
sf::st_write(srk_sub, "/home/ascharf/Downloads/testshp", layer="stork_pts", driver="ESRI Shapefile", delete_layer = TRUE) # for overwriting


# 2. I tried removing the "sensor_type_ids" but there are more duplicated abbrevated names
# 3. I tried using only the track attributes, but these also contain duplicated abbrevated names
# 4. there is probably a way to reduce the attribute names to max 10 char, than rename all the ones that are duplicated, and than rename all columns in the move2 obj, and convert it into a shp. The function used in st_write to abreviate names is here: https://github.com/r-spatial/sf/blob/80edf9535087f9aa6c47bd214794e8d074df88f7/R/read.R#L372. But when I use this line "fld_names <- abbreviate(fld_names, minlength = 7)" I obtain other abreviations than the ones given by st_write(). Clueless...

## Save as a Shapefile -> Lines
## seg and lines do not work because of duplicated abrev column names, so just selecting basics
srk_allattrb_seg_sub <- select(srk_allattrb_seg, mt_time_column(srk), geometry, mt_track_id_column(srk))
sf::st_write(srk_allattrb_seg_sub, "/home/ascharf/Downloads/testshp", layer="stork_segm", driver="ESRI Shapefile", delete_layer = TRUE)

srk_noattrb <- srk_allattrb %>% select(!(everything())) ## to just keep track id
srk_sub_lines <- mt_track_lines(srk_allattrb)
sf::st_write(srk_sub_lines, "/home/ascharf/Downloads/testshp", layer="stork_lines", driver="ESRI Shapefile", delete_layer = TRUE)

### Save as a GeoPackage, points and lines
sf::st_write(srk_allattrb, dsn="/home/ascharf/Downloads/testgpkg/stork_pts.gpkg", driver="GPKG", delete_layer = TRUE) # for overwriting
sf::st_write(srk_allattrb_seg, dsn="/home/ascharf/Downloads/testgpkg/stork_segm.gpkg", driver="GPKG", delete_layer = TRUE) # for overwriting
sf::st_write(srk_lines, dsn="/home/ascharf/Downloads/testgpkg/stork_lines.gpkg", driver="GPKG", delete_layer = TRUE) # for overwriting


### Save as KML, points and lines
sf::st_write(srk_allattrb, dsn = "/home/ascharf/Downloads/testkml/stork_pts.kml", driver="kml", delete_layer = TRUE)
sf::st_write(srk_allattrb_seg, dsn="/home/ascharf/Downloads/testkml/stork_segm.kml", driver="kml", delete_layer = TRUE)
sf::st_write(srk_lines, dsn="/home/ascharf/Downloads/testkml/stork_lines.kml", driver="kml", delete_layer = TRUE)
