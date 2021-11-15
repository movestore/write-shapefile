# Write Shapefile
MoveApps

Github repository: *github.com/movestore/write-shapefile*

## Description
Transformation of the input data to a set of downloadable shapefile files, singly in a folder or zipped.

## Documentation
The input Movement data set is transformed into a spatial points data frame that is then written into a shapefile folder with the writeOGR function. This creates the four characteristic shapefile files that can then be downloaded as a folder of artefacts from the MoveApps output. This set of files can then be uploaded to a GIS software for further analysis and visualisation. The original data set is also passed on as output to a possible next App.

Using the zip-package, the four shapefile files are jointed to a zip file. 

Note that the column names of the data set are shortened to 10 characters, which might often give problems to reconstruct their meaning. Refer to a csv that you can write with the rds2csv App, the order of columns is not changed.

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
`data_shps.zip`: zipped file containing the shapefile files for input to a GIS software. The four files are `data.dbf`, `data.prj`, `data.shp` and `data.shx`, and contain all tracking data of the input data set.

### Parameters 
no parameters

### Null or error handling:
**Data:** The full input data set is returned for further use in a next App and cannot be empty.
