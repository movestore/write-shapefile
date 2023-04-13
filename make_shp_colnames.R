# add no-vowel names and cut them to 10 digits

library(stringr)

ta <- read.csv("MovebankVocab_shapefileNames0.csv",header=TRUE)

shortname_novoc<- apply(matrix(ta$name),1,function(x) stringr::str_replace_all(x, "[aeiou ]", ""))

shortname_novoc_max10 <- substring(shortname_novoc,1,10)

tax <- data.frame(ta[,1:3],shortname_novoc,shortname_novoc_max10,ta[,4:6])

write.csv(tax,"MovebankVocab_shapefileNames_wNoVowels.csv",row.names=FALSE)
