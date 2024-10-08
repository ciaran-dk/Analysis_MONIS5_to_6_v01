#!/usr/bin/env Rscript
# -*- coding: utf-8 -*-

#____________________________________________________________________________#
# R-code provided for the project:
# 
# “MONIS6”
#
# Authors: Steen Wilhelm Knudsen.

# Change the working directory to a path on your own computer , and run
# the individual parts below to reproduce the diagrams presented in the paper
#
# All input data required needs to be available as csv-files in the same directory 
# as this R-code use for working directory.
#
# Occassionally the code will have difficulties producing the correct diagrams,
# if the packages and libraries are not installed.
# Make sure the packages are installed, and libraries are loaded, if the R-code
# fails in producing the diagrams.
#
#________________IMPORTANT!!_________________________________________________#
# (1)
#You have to change the path to the working directory before running this code
#
#
#____________________________________________________________________________#
# # remove everything in the working environment, without a warning!!
# rm(list=ls())
#see this
#website
#on how to only install required packages
#https://stackoverflow.com/questions/4090169/elegant-way-to-check-for-missing-packages-and-install-them
# if (!require("pacman")) install.packages("pacman")
# pacman::p_load(
#   scales, 
#   fields, 
#   gplots,
#   plyr)

library(fields)
library(gplots)
library(officer)
library(plyr)
library(scales)
library(envDocument)
library(tableHTML)

## install the package 'scales', which will allow you to make points on your plot more transparent
#install.packages("scales")
# if(!require(scales)){
#   install.packages("scales")
#   library(scales)
# }
#install.packages("fields")
# if(!require(fields)){
#   install.packages("fields")
#   library(fields)
# }
## install the package 'gplots', to be able to translate colors to hex - function: col2hex
#install.packages("gplots")
# if(!require(gplots)){
#   install.packages("gplots")
#   library(gplots)
# }
## install the package 'glad', to be able to color using the function 'myPalette'
#install.packages("glad")
#library(glad)

#get package to read excel files
#install.packages("readxl")
#library(readxl)
#get package to do count number of observations that have the same value at earlier records:
# see this website: https://stackoverflow.com/questions/11957205/how-can-i-derive-a-variable-in-r-showing-the-number-of-observations-that-have-th
#install.packages("plyr")
# install package if required
# if(!require(plyr)){
#   install.packages("plyr")
#   library(plyr)
# }

#get package to make maps - see this website: http://www.molecularecologist.com/2012/09/making-maps-with-r/
#install.packages("mapdata")
#library(mapdata)
# install package if required
# if(!require(officer)){
#   install.packages("officer")
#   library(officer)
# }
#library(ReporteRs)

#install.packages("tableHTML")
#https://cran.r-project.org/web/packages/tableHTML/vignettes/tableHTML.html
# install package if required
# if(!require(tableHTML)){
#   install.packages("tableHTML")
#   library(tableHTML)
# }
library(tableHTML)
# install package if required
# if(!require(envDocument)){
#   install.packages("envDocument")
#   library(envDocument)
# }
library(envDocument)
#name working directory
#wd00 ="/home/hal9000/Documents/Documents/NIVA_Ansaettelse_2021/MONIS6/Analysis_MONIS5_to_6"

wd00 <- getwd()
#wd00 = "/Users/steenknudsen/Documents/Documents/NIVA_Ansaettelse_2020/NOVANA_proever_2018_2019"
# define dir w output files
wd03 <- "output03_match_MONIS_conc_on_extraction_with_water_sample"

#set working directory
#setwd(wd00)
# pate together a path for the data directory
wd01 <- paste0(wd00,"/data")
#make complete path to output dir
wd00_wd03 <- paste(wd00,"/",wd03,sep="")
wd05 <- "output04_stdcrv_plots_and_tables_from_Rcode_for_MST2017_2023_samples"
#make complete path to output dir
wd00_wd05 <- paste(wd00,"/",wd05,sep="")
#check the wd
#Delete any previous versions of the output directory
unlink(wd00_wd05, recursive=TRUE)
#Create a directory to put resulting output files in
dir.create(wd00_wd05)
# # set working directory
# setwd(wd00)
# getwd()

#_______________________________________________________________________________
inf_tbl04 <- "table04_combined_MST_samples_and_qpcr_data.csv"
wd00_wd03_inf04 <- paste0(wd00_wd03,"/",inf_tbl04)
#
smpls01 <- read.csv(wd00_wd03_inf04, header = TRUE, sep = ";",
                    quote = "\"",
                    dec = ".", fill = TRUE, comment.char = "",
                    stringsAsFactors = FALSE)
# define input file with list of all assays
inf05 <- "lst_assays_MO5_2021apr.csv"
# paste path and input file together
pthf05 <- paste0(wd01,"/",inf05)
# read in the file with the list of all assays
tblass <- read.csv(pthf05, header = TRUE, sep = ",",
                    quote = "\"",
                    dec = ".", fill = TRUE, comment.char = "",
                    stringsAsFactors = FALSE)

# the list of assays incl an old species name
#grep for this name and make a separate data frame
df_Psever <- tblass[grepl("Pse.*serruculata",tblass$Lat_Species), ]
#then replace in this df for some of the names that have changed
tblass$Lat_Species <- gsub("serruculata","verruculosa",tblass$Lat_Species)
tblass$species <- gsub("serruculata","verruculosa",tblass$species)
tblass$Lat_Species <- gsub("Magallana", "Crassostrea",tblass$Lat_Species)
tblass$species <- gsub("Magallana", "Crassostrea",tblass$species)

unique(tblass$Common_name_Danish)
# make a new column with underscores instead of space in species names
tblass$gen_specnm <- gsub(" ","_",tblass$Lat_Species)
# split text - see: https://stevencarlislewalker.wordpress.com/2013/02/13/remove-or-replace-everything-before-or-after-a-specified-character-in-r-strings/
# and concatenate text - see: https://stackoverflow.com/questions/7201341/how-can-2-strings-be-concatenated
# to get 6 letter abbr of latin speciesnames
ls.abbr.spcnm <-  paste(
  substr(sub('\\_.*', '', tblass$gen_specnm), 1, 3),
  substr(sub('.*\\_', '', tblass$gen_specnm), 1, 3),
  sep="."
)
#add back on to latin name dataframe
tblass$abbr.nm <- ls.abbr.spcnm
#
smpls02 <- smpls01
#remove "No Ct"
#smpls02<-smpls02[!grepl("NoCt", smpls02$Quantitycopies),]
#smpls02<-smpls02[!grepl("NaN", smpls02$Quantitycopies),]
# replace NaN and NoCt with 0
# smpls02$Quantitycopies[grepl("NaN", smpls02$Quantitycopies)] <- 0
# smpls02$Quantitycopies[grepl("NoCt", smpls02$Quantitycopies)] <- 0

#remove ROX from BiRad dataset
#smpls02<-smpls02[!grepl("ROX", smpls02$Fluor),]

#change x into numeric variable
smpls02$CtdRn=as.numeric(as.character(smpls02$CtdRn))
smpls02$Quantitycopies=as.numeric(as.character(smpls02$Quantitycopies))
#nrow(smpls02)
#substitute point in short abbreviated name
tblass$abbr.nm2 <- gsub("\\.","",tblass$abbr.nm)
#match between dataframes to add latin species names and DK common names
smpls02$gen_specnm <- tblass$Lat_Species[match(smpls02$speciesabbr, tblass$abbr.nm2)]
smpls02$Genus <- tblass$Genus[match(smpls02$speciesabbr, tblass$abbr.nm2)]
smpls02$species <- tblass$species[match(smpls02$speciesabbr, tblass$abbr.nm2)]
smpls02$dk_comnm <- tblass$Common_name_Danish[match(smpls02$speciesabbr, tblass$abbr.nm2)]

# identify dates and NAs and use the dates in an object
dt.nNA <- smpls02$Dato_inds[!is.na(smpls02$Dato_inds)]
smpls02$mnt <- NA
#get month abbreviation
mnt.dt.nNA <- month.abb[as.numeric(gsub("^.*-(.*)-.*$","\\1",dt.nNA))]
smpls02$mnt[!is.na(smpls02$Dato_inds)] <- mnt.dt.nNA
#get year
smpls02$yea <- NA
yea.dt.nNA <- as.numeric(gsub("^(.*)-(.*)-.*$","\\1",dt.nNA))
smpls02$yea[!is.na(smpls02$Dato_inds)] <- yea.dt.nNA

# Check which samples are missing a sample year - start 
#____________________________________________________

#____________________________________________________
# Check which samples are missing a sample year - end
#copy the MST.nummer column
smpls02$MST_no02 <- gsub("MST","",smpls02$MST.nummer)
#paste a new column based on variables separated by point
smpls02$MST.y.m <- paste("MST",smpls02$MST_no02, smpls02$yea,smpls02$mnt,  sep=".")
#assign MST smpls to spring season or to fall season
smpls02$ssn <- ifelse(
  as.numeric(gsub("^.*-(.*)-.*$","\\1",
                  smpls02$Dato_inds))<=7,
  "spri","fall")
#pad with zeros to two characters
#see this website: https://stackoverflow.com/questions/5812493/adding-leading-zeros-using-r
smpls02$MST_no03 <- stringr::str_pad(smpls02$MST_no02, 7, pad = "0")
#make a column w MST in front of MST number
smpls02$MST_no04 <- paste("MST",smpls02$MST_no03,sep="")
#add sampling no and smapl mnt and smpl year to qPCR data
smpls02$smpltp2 <- smpls02$smpltp
# grep for only MST numbers
MSTNos <- smpls02$smpltp2[grepl("MST",smpls02$smpltp2)]
# substitute in only the MST numbers
MSTNos <- gsub("MST","",MSTNos)
MSTNos <- gsub("-","",MSTNos)
#pad with zeros to two characters
#see this website: https://stackoverflow.com/questions/5812493/adding-leading-zeros-using-r
MSTNos <- stringr::str_pad(MSTNos, 7, pad = "0")
# paste back the MST prefix
MSTNos<- paste0("MST",MSTNos)
# replace the matched MST nos
smpls02$smpltp2[grepl("MST",smpls02$smpltp2)] <- MSTNos

#smpls02[is.na(smpls02$gen_specnm),]
#paste a new column based on variables separated by point
smpls02$Wellname.ssn.no1 <- paste(smpls02$Well, smpls02$ssn, "1",  sep=".")
#paste a new column based on variables separated by point
smpls02$gen_specnm.ssn <- paste(gsub(" ","_",smpls02$gen_specnm), smpls02$ssn,  sep=".")
#paste a new column based on variables separated by point
smpls02$gen_specnm.ssn <- paste(gsub(" ","_",smpls02$gen_specnm), smpls02$ssn,  sep=".")
# copy columns to have a new column with a new name that matches the coming code
smpls02$locnm <- smpls02$Lok_omr01
smpls02$colldate <- smpls02$Dato_inds
smpls02$volfilt_mL <- smpls02$Vwf_mL
# 
# in Danish: 'brededegrad' = English: 'latitude'
# in Danish: 'længdegrad' = English: 'longitude'
smpls02$declat <- smpls02$lok_pos_lat
smpls02$declon <- smpls02$lok_pos_lon

#assign extra columns to match column names used in previous versions of this code
## On the BioRad machine this replNo is stored under 'content'
#smpls02$Welltype <- gsub("^(.*)-(.*)$","\\1",smpls02$Content)
smpls02$Welltype <- smpls02$WellType
smpls02$Harbour <- smpls02$locnm

#paste a new column based on variables separated by point
smpls02$Harbour.Welltype <- paste(smpls02$Harbour,
                                  smpls02$Welltype,  sep=".")
#get the unique smpl names for Harbours and WellTypes
unHaWT <- unique(smpls02$Harbour.Welltype)
# make a transparent color
transp_col <- rgb(0, 0, 0, 0)
#transp_col <- as.character("#FFFFFF")
HaWTnoNA <- addNA(unHaWT)
col.01<-as.numeric(as.factor(unHaWT))
#make a small dataframe w harbours and standards and numbers assigned, 
#use the col2hex in gplot pacakge to convert the 'red' color name to hex-color
col.02 <- col2hex(palette(rainbow(length(col.01))))
harbourcols <- cbind(unHaWT,col.01, col.02)
#replace the colour for the standard dilution sample type with the transparent colour
col.03<-replace(col.02, col.01==15, transp_col)
col.04 <- cbind(harbourcols,col.03)
colforharb <- as.data.frame(col.04)
#match to main data frame and add as new color
smpls02$col.06 <- colforharb$col.03[match(smpls02$Harbour.Welltype, colforharb$unHaWT)]
#unique(smpls02$Harbour.Welltype)
#insert the transparent color for all matches with "NA.Standard"
smpls02$col.06[smpls02$Harbour.Welltype=="NA.Standard"] <- transp_col
smpls02$col.06[smpls02$Harbour.Welltype=="NA.Std"] <- transp_col
#get replicate number
smpls02$replno <- smpls02$replno
# On the BioRad machine this replNo is stored under 'content'
#smpls02$replno <- gsub("^.*-(.*)$","\\1",smpls02$Content)
#paste together with qpcr number
smpls02$qpcr.rplno<- paste(smpls02$qpcrno,smpls02$replno,sep=".")
#use 'gsub' to retain part of string to get welltype
# On the BioRad machine this replNo is stored under 'content'
#smpls02$welltp <- gsub("(^.*)-(.*)$","\\1",smpls02$Content)
smpls02$welltp <- smpls02$WellType 


####################################################################################
#
# prepare std dilution curve plots for each for species
#
####################################################################################
#smpls02[is.na(smpls02$gen_specnm),]
#get the unique species names
latspecnm <- unique(smpls02$gen_specnm)
#match the assay number to the data frame with species
AIfps <- tblass$Assay_ID[match(gsub(" ","_",latspecnm), tblass$gen_specnm)]
#pad with zeros to two characters
#see this website: https://stackoverflow.com/questions/5812493/adding-leading-zeros-using-r
AIfps <-stringr::str_pad(AIfps, 2, pad = "0")
#make a new data frame with assay Id No and species
nlspnm <- data.frame(AIfps,latspecnm)
#reorder by the column 'AssayIDNo'
nlspnm<- nlspnm[order(nlspnm$AIfps),]
#make a list of numbers for the unique species
no.latspc <- seq(1:length(latspecnm))
#add a new column with no to use for appendix numbering
nlspnm <- cbind(nlspnm, no.latspc) 
#use the new order of latin species names for producing plots
latspecnm <- unique(nlspnm$latspecnm)
#copy the data frame
amp <- smpls02
######################################################################################
#   make standard curve plots for each species for each season 
######################################################################################
# dev.off()

smpls02$qpcrno.plateno <- paste(smpls02$qpcrno,smpls02$plateno,sep=".")
#head(smpls02)
########################################################
# for loop start here
########################################################
#define a number of variables you want to collect
varsr <- 10
#make empty lists where values from each run can be added
#make  a number to ad to while terating over files
i <- 1
#make empty lists
#get number of qpcr files
no.ofqpcrruns <- length(unique(smpls02$qpcrno.plateno))
no.ofspcs <- length(unique(smpls02$species))
no.ofyrssmpl <- length(unique(smpls02$yea))
#make an empty list to accumulate all matrices
qrpsc <- list()
# loop over all species names in the unique list of species, and make plots. 
#Notice that the curly bracket ends after the pdf file is closed
for (spec.lat in latspecnm){
  print(spec.lat)
  # #}
  #get the Danish commom name
  #first split the string by the dot
  #https://stackoverflow.com/questions/33683862/first-entry-from-string-split
  #and escape the dot w two backslashes
  latnm <- sapply(strsplit(spec.lat,"\\."), `[`, 1)
  sbs.dknm <- tblass$Common_name_Danish[match(gsub(" ","_",latnm), tblass$gen_specnm)]
  #get AssIDNo
  sbs.AssIDNo <- tblass$Assay_ID[match(gsub(" ","_",latnm), tblass$gen_specnm)]
  #get Abbreviated name
  sbs.abbr.nm <- tblass$abbr.nm[match(gsub(" ","_",latnm), tblass$gen_specnm)]
  #get the number for the appendix plot number
  AIfps <- nlspnm$no.latspc[match(gsub("_"," ",latnm), nlspnm$latspecnm)]
  no.spc.app.plot <-stringr::str_pad(AIfps, 2, pad = "0")
  #get the latin species nam without underscore
  spec.lat.no_undersc <- paste(sub('_', ' ', spec.lat))
  #define path to where to write the file
  wd00_05 <- paste0(wd00,"/",wd05)
  
  #subset based on variable values, subset by species name and by season
  sbs.amp2 <- amp[grepl(spec.lat.no_undersc,amp$gen_specnm),]
  #count unique qPCR plates 
  ungqpcrNos <- unique(sbs.amp2$qpcrno)
  unqplts <- unique(sbs.amp2$plateno)
  nplts <- length(unqplts)
  nqpcrs <- length(ungqpcrNos)
  nfplts <- seq(1:nplts)
  nfpcrs <- seq(1:nqpcrs)
  ltfplts <- letters[nfplts]
  ltfpcrss <- letters[nfpcrs]
  #bind columns together and make it a dataframe
  # for the plates 
  df_plts <- as.data.frame(cbind(unqplts,nplts,nfplts,ltfplts))
  # and for the individual qPCRs
  df_pcrs <- as.data.frame(cbind(ungqpcrNos,nqpcrs,nfpcrs,ltfpcrss))
  #make it a matrix to be able to add values to it
  mtx_plts1 <- as.matrix(df_plts)
  nrdpl <- nrow(df_plts)
  nrdpl <- nrow(df_pcrs)
  #assign to a different variable
  iter <- no.ofspcs
  #make a variable that defines number of columns for a matrix
  vars = 15
  vars = 12
  #assign to a different variable
  iter <- no.ofspcs
  #prepare an empty matrix w enough rows
  mtx_plts2 <- matrix(ncol=vars, nrow=nrdpl)
  
  # set a parameter for the number of panes per row
  pprw <- 4
  # with 4 panes per row per plot, then the resulting plot needs to have
  # panes enough for the no pf qpcrs divided by 4, and rounded up
  # to have panes enough in the plot. The number of panes is used in
  # plot arrangement
  noofpns <- ceiling(nqpcrs/pprw)
  
  
  # # Exporting PFD files via postscript()           
  # pdf(c(paste(wd00_10,"/","suppmatr_10.04b_App_A",no.spc.app.plot,
  #             "_stddilser_",sbs.abbr.nm,".pdf",  sep = ""))
  #     ,width=(1.6*8.2677),height=(2*1.6*2*2.9232))
  #try saving as jpeg instead - then comment out the 'pdf' part above
  jpeg(c(paste(wd00_05,"/","App_05_",no.spc.app.plot,
               "_stddilser_",sbs.abbr.nm,".jpg",  sep = ""))
       ,width=(1.6*8.2677),height=(2*1.6*2*2.9232),
       units="in",res=300,pointsize=16)
  #op <- par(mar = c(5, 4, 0.05, 0.05) + 0.1) # c(low, left, top, right))
  #op <- par(mfrow=c(2,1), # set number of panes inside the plot - i.e. c(2,2) would make four panes for plots
            # the 1st number is the number of rows, the 2nd number is the number of columns
  op <- par(mfrow=c(pprw,noofpns),          
            oma=c(1,1,0,0), # set outer margin (the margin around the combined plot area) - higher numbers increase the number of lines
            mar=c(4,4,2,2),# set the margin around each individual plot - the positions in the paranthese equals :(b,l,t,r) = (bottom, left, top , right)
            adj = 0 # adjust the text 
  )
  
  # set a number for the growing number of elements in the list
  k <- 1
  #iterate over plates
  for (plt in df_pcrs$ungqpcrNos  ){
    print(plt)
    #}
    #get subfig letter for plat number
    pltlet <- df_pcrs$ltfpcrss[match(plt,df_pcrs$ungqpcrNos)]
    #  limit data frame to qPCR-run No
    sbs.amp <- sbs.amp2[grepl(plt,sbs.amp2$qpcrno),]
    #View(sbs.amp)
    #limit the data frame to only include samples that amplified with a Cq
    # i.e. omit those where Cq is NaN
    # On the Mxpro machine the Ct column is named 'CtdRn'
    sbs.amp <- sbs.amp[!is.na(sbs.amp$CtdRn),]
    #sbs.amp <- sbs.amp[!is.na(sbs.amp$Cq),]
    
    qpcrno <- unique(sbs.amp$qpcrno)
    #identify LOD
    lod.id.df<-sbs.amp[(sbs.amp$WellType=='Standard'),]
    # Comment out this line above if you use data from the BioRad
    # and then instead uncomment the line below if you did not
    # us the MxPro
    #lod.id.df<-sbs.amp[(sbs.amp$Welltype=='Std'),]
    lod.val<-min(lod.id.df$Quantitycopies)
    #identify LOQ
    #limit the dataframe to only well type that equals standard
    #zc<-sbs.amp[(sbs.amp$Welltype=='Std'),] # use this line if your data comes from BioRad
    zc<-sbs.amp[(sbs.amp$Welltype=='Standard'),] # use this line if your data comes from MXPro
    #count the occurences of dilution steps - i.e. the number of succesful replicates
    #see this webpage: https://www.miskatonic.org/2012/09/24/counting-and-aggregating-r/
    #zd<-count(zc, "WellName")
    zd <- dplyr::count(zc, Quantitycopies)
    #turn this into a dataframe
    ze<-as.data.frame(zd)
    #match the dilution step to the number of occurences -i.e. match between the two dataframes
    no.occ <- ze$n[match(zc$Quantitycopies,ze$Quantitycopies)]
    #add this column with counted occurences to the limited dataframe
    zg <- cbind.data.frame(zc,no.occ)
    #get the maximum number of replicates - should be three
    mxnrpl<- max(no.occ)
    #exlude all observations where less than 3 replicates amplified
    zh<-zg[(zg$no.occ>=mxnrpl),]
    #get the lowest dilution step that succesfully ampllified on all 3 repliactes
    loq.val=min(zh$Quantitycopies)
    # find the uL of template used for the setup
    tmplvol.add <- unique(as.numeric(gsub("uL","",sbs.amp$templvol)))
    #Conditionally Remove Dataframe Rows with R
  
    #https://stackoverflow.com/questions/8005154/conditionally-remove-dataframe-rows-with-r
    #sbs.pamp<-sbs.amp[!(sbs.amp$Welltype=='Std' & sbs.amp$Quantitycopies<=5),] # use this line if you used BioRad
    #sbs.pamp<-sbs.amp[!(sbs.amp$Welltype=='Standard' & sbs.amp$Quantitycopies<=3),] # use this line if you used MXpro
    sbs.pamp<-sbs.amp[!(sbs.amp$Welltype=='Standard' & sbs.amp$Quantitycopies<=tmplvol.add),] # use this line if are using the above line for evaluating the volume of template added
    #__________________# plot1   - triangles________________________________________
    ##  Create a data frame with eDNA
    y.sbs.amp <- sbs.amp$CtdRn
    x.sbs.amp <- sbs.amp$Quantitycopies
    d.sbs.famp <- data.frame( x.sbs.amp = x.sbs.amp, y.sbs.amp = y.sbs.amp )
    #subset to only include the standard curve points
    # to infer the efficiency of the assay.
    #sbs02_df <- sbs.amp[sbs.amp$Welltype=="Std", ] # use this line if you used BioRad
    sbs02_df <- sbs.amp[sbs.amp$Welltype=="Standard", ] # use this line if you used MXpro
    sbs02_df$CtdRn[is.na(sbs02_df$CtdRn)] <- 0
    #calculate the covariance
    cov_sbs02 <- cov(sbs02_df$CtdRn, sbs02_df$Quantitycopies)
    #calculate the correlation
    cor_sbs02 <- cor(-log10(sbs02_df$Quantitycopies), sbs02_df$CtdRn)*100
    rcor_sbs02 <- round(cor_sbs02, 3)
    #begin plot
    plot(
      y.sbs.amp ~ x.sbs.amp,
      data = d.sbs.famp,
      type = "n",
      log  = "x",
      las=1, # arrange all labels horizontal
      xaxt='n', #surpress tick labels on x-axis
      yaxt='n', #surpress tick labels on y-axis
      # #add a title with bquote
      main=c(bquote(~'('~.(as.character(pltlet))~') '
                    
                    ~italic(.(spec.lat.no_undersc))
                    ~'('~.(as.character(plt))~') '
      )),
      # change the size of the main title for each plot
      # https://stackoverflow.com/questions/4241798/how-to-increase-font-size-in-a-plot-in-r
      cex.main=0.8,
      cex.lab=0.8,
      #Change axis names
      xlab="target-eDNA in extract. (copy/qPCR-reaction)",
      ylab="Cq",
      # define boundaries for plotting area
      xlim = c( 0.234, 0.428*1000000000 ),
      ylim = c( 9.55, 48.446 )
      #end plot area -  next parts will add more to the plot area 
    )
    #define positioning for labels to the points
    pos_vector <- rep(3, length(sbs.amp$Harbour))
    #add labels to the points
    text(x.sbs.amp, y.sbs.amp, labels=sbs.amp$Harbour, cex= 0.8, pos=pos_vector, las=3)
    ##  Put grid lines on the plot, using a light blue color ("lightsteelblue2").
    # add horizontal lines in grid
    abline(
      h   = c( seq( 8, 48, 2 )),
      lty = 1, lwd =0.6,
      col = colors()[ 225 ]
    )
    # add vertical lines in grid
    abline(
      v   = c( 
        seq( 0.1, 1, 0.1 ),
        seq( 1e+0, 1e+1, 1e+0 ),
        seq( 1e+1, 1e+2, 1e+1 ),
        seq( 1e+2, 1e+3, 1e+2 ),
        seq( 1e+3, 1e+4, 1e+3 ),
        seq( 1e+4, 1e+5, 1e+4 ), 
        seq( 1e+5, 1e+6, 1e+5 ),
        seq( 1e+6, 1e+7, 1e+6 ),
        seq( 1e+7, 1e+8, 1e+7 ),
        seq( 1e+8, 1e+9, 1e+8 )),
      lty = 1, lwd =0.6,
      col = colors()[ 225 ]
    )
    # add line for LOQ
    abline(v=loq.val, lty=2, lwd=1, col="mediumorchid4")
    text(loq.val*0.7,15,"LOQ",col="mediumorchid4",srt=90,pos=1, font=1)
    # add line for LOD 
    abline(v=lod.val, lty=1, lwd=1, col="blue")
    text(lod.val*0.7,22,"LOD",col="blue",srt=90,pos=1, font=1)
    # add line for Ct-cut-off
    abline(h=seq(41,100,1000), lty=1, lwd=3, col="darkgray")
    text(1e+4,40.6,"cut-off",col="darkgray",srt=0,pos=3, font=2, cex=1.2)
    ##  Draw the points over the grid lines.
    points( y.sbs.amp ~ x.sbs.amp, data = d.sbs.famp, 
            pch=c(24), lwd=1, cex=1.8,
            bg=as.character(sbs.amp$col.06)
    )
    #edit labels on the x-axis
    ticks <- seq(-1, 9, by=1)
    labels <- sapply(ticks, function(i) as.expression(bquote(10^ .(i))))
    axis(1, at=c(0.1, 1, 10, 1e+2, 1e+3, 1e+4, 1e+5, 1e+6, 1e+7, 1e+8, 1e+9), pos=8, labels=labels)
    #edit labels on the y-axis
    axis(side=2, at=seq(8, 50, by = 2), las=1, pos=0.1)
    #estimate a model for each STD subset incl below LOQ
    sbs.amp$x <- sbs.amp$Quantitycopies
    sbs.amp$y<- sbs.amp$CtdRn
    # calculate the log10 for for the Quantitycopies
    sbs.amp$log10x <- log10(sbs.amp$Quantitycopies)
    #estimate a linear model 
    logEst.amp_STD <- lm(y~log(x),sbs.amp)
    # calculate the log10 for for the Quantitycopies
    sbs.amp$log10x <- log10(sbs.amp$Quantitycopies)
    #estimate a linear model 
    logEst.amp_STD <- lm(y~log(x),sbs.amp)
    #estimate a linear model for the log10 values
    # to get the slope
    log10xEst.amp_STD <- lm(y~log10x,sbs.amp)
    #add log regresion lines to the plot
    with(as.list(coef(logEst.amp_STD)),
         curve(`(Intercept)`+`log(x)`*log(x),add=TRUE,
               lty=1))
    #estimate a model for each STD subset for dilution steps above LOQ
    ab.loq.sbs.amp<-zh # get the previously limited dataframe from identifying LOQ
    ab.loq.sbs.amp$x <- ab.loq.sbs.amp$Quantitycopies
    ab.loq.sbs.amp$y<- ab.loq.sbs.amp$CtdRn
    logEst.abloqamp_STD <- lm(y~log(x),ab.loq.sbs.amp) #make a linear model
    #get the slope to calculate the efficiency
    slo1 <- log10xEst.amp_STD$coefficients[2]
    slo2 <- as.numeric(as.character(slo1))
    # get intercept
    intc1 <- log10xEst.amp_STD$coefficients[1]
    intc2 <- as.numeric(as.character(intc1))
    # If log(x) = -1.045
    #Then x = 10^-1.045 = 0.09015711
    #slo3 = 10^slo2
    #
    #Effic <- (-1/slo2)*100
    #Try with perfect efficiency
    #2^3.3219400300021
    #slo2 = -3.3219400300021
    #https://www.gene-quantification.de/efficiency.html
    #qPCR efficiency
    Effic <- (-1+(10^(-1/slo2)))*100
    #amplification factor
    ampF <- 10^(-1/slo2)
    rEffic <- round(Effic,2)
    intc3 <- round(intc2,2)
    slo3 <- round(slo2,2)
    #add log regresion lines to the plot
    with(as.list(coef(logEst.abloqamp_STD)),
         curve(`(Intercept)`+`log(x)`*log(x),add=TRUE,
               lty=1, col="red"))
    #add 95% confidence intervals around each fitted line
    #inspired from this webpage
    #https://stat.ethz.ch/pipermail/r-help/2007-November/146285.html
    #for the first line - with below LOQ
    newx<-seq(lod.val,1e+6,1000)
    prdlogEst.amp_STD<-predict(logEst.amp_STD,newdata=data.frame(x=newx),interval = c("confidence"), 
                               level = 0.95, scale=0.95 , type="response")
    prd2logEst.amp_STD<- prdlogEst.amp_STD
    #polygon(c(rev(newx), newx), c(rev(prd2[ ,3]), prd2[ ,2]), col = 'grey80', border = NA)
    lines(newx,prd2logEst.amp_STD[,2],col="black",lty=2)
    lines(newx,prd2logEst.amp_STD[,3],col="black",lty=2)
    #add 95% conf. intervals for the second line - only above LOQ
    newx<-seq(loq.val,1e+6,100)
    prdlogEst.abloqamp_STD<-predict(logEst.abloqamp_STD,newdata=data.frame(x=newx),interval = c("confidence"), 
                                    level = 0.95, scale=0.95 , type="response")
    prd2logEst.abloqamp_STD<- prdlogEst.abloqamp_STD
    #polygon(c(rev(newx), newx), c(rev(prd2[ ,3]), prd2[ ,2]), col = 'grey80', border = NA)
    lines(newx,prd2logEst.abloqamp_STD[,2],col="red",lty=2)
    lines(newx,prd2logEst.abloqamp_STD[,3],col="red",lty=2)
    # add a legend for colors on points
    legend(1e+5*0.5,49,
           unique(sbs.amp$Harbour.Welltype),
           pch=c(24),
           bg="white",
           #NOTE!! the hex color numbers must be read as characters to translate into hex colors
           pt.bg = as.character(unique(sbs.amp$col.06)),
           y.intersp= 0.7, cex=0.7)
    # add a second legend for types of regression lines
    legend(1e+2,49,
           c("incl below LOQ","excl below LOQ"),
           #pch=c(24), #uncomment to get triangles on the line in the legend
           cex=0.7,
           bg="white",
           lty=c(1), col=c("black","red"),
           y.intersp= 0.8)
    # add a third legend for efficiency and R2
    legend(1e+5*0.5,38,
           c(paste("efficiency: ",rEffic," %",sep=""),
             paste("R2: ",rcor_sbs02,sep=""),
             paste("equation: y=",slo3,"log(x) +",intc3,sep="")),
           #pch=c(24), #uncomment to get triangles on the line in the legend
           cex=0.7,
           bg="white",
           #lty=c(1), col=c("black","red"),
           y.intersp= 1.0)
    
    #______________________________________________________________________
    #get the slope to calculate the efficiency
    #log10xEst.amp_STD$coefficients[2]
    slo1 <- log10xEst.amp_STD$coefficients[2]
    slo2 <- as.numeric(as.character(slo1))
    intc1 <- log10xEst.amp_STD$coefficients[1]
    intc2 <- as.numeric(as.character(intc1))
    Effic <- (-1+(10^(-1/slo2)))*100
    #amplification factor
    ampF <- 10^(-1/slo2)
    rEffic <- round(Effic,2)
    intc3 <- round(intc2,2)
    slo3 <- round(slo2,2)
    RSqdRn <- rcor_sbs02
    
    if (length(unique(substr(
      as.character(sbs.amp$Quantitycopies[(sbs.amp$Welltype=="Standard")])
      ,1,1))) < 2){
      templvol <- paste(unique(substr(
        as.character(sbs.amp$Quantitycopies[(sbs.amp$Welltype=="Standard")])
        ,1,1)),"uL",sep="")} else {templvol <- "3uL"}
    
    #find intersection between linear regression and LOD
    intc4<-slo2*(log10(lod.val))+intc2
    intc5 <- round(intc4,3)
    mx.Cq.lod<- max(na.omit(sbs.amp$CtdRn[lod.val==sbs.amp$Quantitycopies]))
    
    #output[i,] <- runif(2)
    mtx_plts2[k,] <- c((as.character(spec.lat)),
                       mx.Cq.lod,intc5,lod.val,loq.val,
                       rEffic,ampF,intc2,slo3,RSqdRn,templvol,(as.character(qpcrno)))
    k <- k+1
    #______________________________________________________________________
    
    ########################################################
    # for loop on seasons end here
    ########################################################
  }    
  #collect the matrix to the list
  qrpsc[[i]]  <- mtx_plts2
  i <- i+1
  # add title for the pdf-page
  mtext(c(paste("out05_Appendix A",no.spc.app.plot,"."),  sep = ""), outer=TRUE, 
        #use at , adj and padj to adjust the positioning
        at=par("usr")[1]+0.15*diff(par("usr")[1:2]),
        adj=3.4,
        padj=2,
        #use side to place it in te top
        side=3, cex=1.6, line=-1.15)
  #apply the par settings for the plot as defined above.
  par(op)
  # end pdf file to save as
  dev.off()  
  #end pdf  
}
########################################################
# for loop on species end here
########################################################
#}
########################################################
l_qrpsc <- length(qrpsc)
#make the list of list one dataframe
# https://stackoverflow.com/questions/29674661/r-list-of-lists-to-data-frame
df_qprps2 <- as.data.frame(do.call(rbind, qrpsc))
#head(df_qprps2)
#change the column names
colnames(df_qprps2) <-
  c("spec.lat",
    "mx.Cq.lod",
    "intc5",
    "lod.val",
    "loq.val",
    "rEffic",
    "ampF",
    "intc2",
    "slo3",
    "RSqdRn",
    "templvol2",
    "qpcrno")

colnames(smpls02)
# join data frames by the sample number and qpcrno number
smpls03 <- dplyr::left_join(smpls02 ,
                              df_qprps2 %>% dplyr::select(
                                everything()),
                              by = "qpcrno")
###############################################################################################
# start -calculate copies per L of filtered water
###############################################################################################
#copy the data frame
smpls02.1 <- smpls02
#set NA blanks to zero
smpls02.1$CtdRn[is.na(smpls02.1$CtdRn)] <- 0
smpls02.1$Quantitycopies[is.na(smpls02.1$Quantitycopies)] <- 0
#set NA blanks to zero
smpls02.1$CtdRn[is.na(smpls02.1$CtdRn)] <- 0
smpls02.1$Quantitycopies[is.na(smpls02.1$Quantitycopies)] <- 0
#make sure numbers are numbers
smpls02.1$Quantitycopies <- as.numeric(as.character(smpls02.1$Quantitycopies))
smpls02.1$volfilt_mL <- as.numeric(as.character(smpls02.1$volfilt_mL))
#set NA blanks to zero
smpls02.1$CtdRn[is.na(smpls02.1$CtdRn)] <- 0
smpls02.1$Quantitycopies[is.na(smpls02.1$Quantitycopies)] <- 0
#add column with copies per Liter of filtered water
#Ae = (Cqpcr /Fe) /Vwf. 
#’Ae’ number of  eDNA-copies per volumen filtered water, 
#’Cqpcr’ number of copies detected in the qPCR-well, #smpls02.1$meanQuantitycopies 
#’Fe’ the ratio of the eluted extrated filtrate used in a qPCR-well #5/350
#’Vwf’ is volumen of seawater filtered. #smpls02.1$volfilt_mL
#per mL
smpls02.1$copies_per_mLwater <- (smpls02.1$Quantitycopies/(3/350))/smpls02.1$volfilt_mL
smpls02.1$copies_per_mLwater <- (smpls02.1$Quantitycopies/(3/400))/smpls02.1$volfilt_mL
#per Liter
smpls02.1$copies_per_Lwater <- smpls02.1$copies_per_mLwater*1000
#replace nas with zeros
smpls02.1$copies_per_Lwater[is.na(smpls02.1$copies_per_Lwater)]<-0
#add one to be able to do logarithmic scales
smpls02.1$copies_per_Lwater_plone<- smpls02.1$copies_per_Lwater+1
#take log10 to all copies
smpls02.1$log.10_copies_L <- log10(smpls02.1$copies_per_Lwater_plone)

#make a variable with path and file
pth_and_fl <- paste(wd00,"/",wd05,"/table05_1_MONIS6_eDNA_smpls02.1.csv", sep="")
pth_and_fl2 <- paste(wd00,"/",wd05,"/table05_2_MONIS6_eDNA_std_crv_efficiencies.csv", sep="")
#write out a csv-file
write.table(smpls02.1, file = pth_and_fl, sep = ";")
#write.table(df_qprps2, file = pth_and_fl2, sep = ";")


###############################################################################################
# end -calculate copies per L of filtered water
###############################################################################################


#get column names
cnm01 <- colnames(smpls01)
cnm02 <- colnames(smpls02.1)


# #