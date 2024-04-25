# Write Shapefile
MoveApps

Github repository: *github.com/movestore/write-shapefile*

## Description
This App transforms the input data to a shapefile(s) containing the locations, line segments and full track lines. Files are contained in a folder that is compressed (.zip) for download. Additionally, geopackages can be requested for each data type.

## Documentation
In the input move2 data set, all track attributes are added to the event attributes, so all information can be written to the selected output files. According to the user's selection, points, segments or track lines can be selected and are written into zipped shapefiles using st_write() from the sf package. For each case, the four characteristic shapefile files are created and can then be downloaded as a zipped folder. This set of files can then be uploaded to a GIS software for further analysis and visualisation. Furthermore, it is possible to request a geopackage file for each of the three types of data. The original move2 data set is also passed on as output to a possible next App.

Note that the shapefile format requires that column (attribute) names be 10 characters or less. Longer names will be shortened to 10 characters, which can result in lost information or difficulty reconstructing the meaning of data attributes. For Movebank attributes, a systematic renaming is in place, for other attributes the (up to) first 10 consonants are used. If this leaves duplicate names, indices are added. In case of doubt, you can use the [Write CSV App](https://www.moveapps.org/apps/browser/4433bb0b-f603-413b-bf79-8e2483825d9c) to obtain a csv file of the data with columns in the same order and containing the original names. Note that renaming is not happening for geopackage files.

### Input data
move2 location object

### Output data
move2 location object

### Artefacts
`data_points_shps.zip`: zipped file containing shapefiles for input to a GIS software. The four files are called as indicated by the user in the setting `file.name` and contain all tracking data as points of the input data set.

`file.name_points.gpkg`: geopacakge containing all tracking data as points of the input data set.

`segments_points_shps.zip`: zipped file containing shapefiles for input to a GIS software. The four files are called as indicated by the user in the setting `file.name` and contain all tracking data as line segments (lines between each pair of successive location points) of the input data set.

`file.name_segments.gpkg`: geopacakge containing all tracking data as lines segments of the input data set.

`lines_points_shps.zip`: zipped file containing shapefiles for input to a GIS software. The four files are called as indicated by the user in the setting `file.name` and contain all tracking data as lines per track of the input data set.

`file.name_lines.gpkg`: geopacakge containing all tracking data as lines per track of the input data set.

### Settings 
**File name (`file.name`):** Provide a file name for the folder containing the shapefile (optional). If none is provided, "moveapps-shapefile" is used.

**Points shapefile (`pts`):** Select if you want to obtain the shapefile with points of the locations. Default TRUE

**Line segments shapefile (`seg`):** Select if you want to obtain the shapefile with line segments between your locations. Default FALSE

**Track lines shapefile (`lins`):** Select if you want to obtain the shapefile with full track lines. Default FALSE

**Geopackage(s) (`gpkg`):** Select if you want to additionally obtain the above selected data in geopackage format. Default FALSE


### Null or error handling:
**Data:** The full input data set is returned for further use in a next App and cannot be empty.

### Most common errors
Please make an issue in this Github repository.

### Null or error handling
**Data:** The full input data set is returned for further use in a next App and cannot be empty.
