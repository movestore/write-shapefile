# Write Shapefile
MoveApps

Github repository: *github.com/movestore/write-shapefile*

## Description
This app transforms the input data to a shapefile. Files are contained in a folder that is compressed (.zip) for download.

## Documentation
The input Movement data set is transformed into a spatial points data frame that is then written into a shapefile folder with the writeOGR function. This creates the four characteristic shapefile files that can then be downloaded as a folder of artefacts from the MoveApps output. This set of files can then be uploaded to a GIS software for further analysis and visualisation. The original data set is also passed on as output to a possible next App.

Using the zip-package, the four shapefile files are combined within a zip file. 

Note that the shapefile format requires that column (attribute) names be 10 characters or less. Longer names will be shortened to 10 characters, which can result in lost information or difficulty reconstructing the meaning of data attributes. You can use the [Write CSV App](https://www.moveapps.org/apps/browser/4433bb0b-f603-413b-bf79-8e2483825d9c) to obtain a csv file of the data with columns in the same order and containing the original names.

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
`data_shps.zip`: zipped file containing the shapefile files for input to a GIS software. The four files are `data.dbf`, `data.prj`, `data.shp` and `data.shx`, and contain all tracking data of the input data set.

### Settings 
**File name (`file.name`):** Provide a file name for the folder containing the shapefile (optional). If none is provided, "moveapps-shapefile" is used.

### Null or error handling:
**Data:** The full input data set is returned for further use in a next App and cannot be empty.
