library(tidyverse)
library(readr)
library(osn)
source('~/RProjects/osn-download/R/osn_query_apt_bbox.R')
source('~/RProjects/osn-download/R/bounding_box_Sam.R')

############### NEW AIRPORT - CHECK BOUNDING BOX ###################
# EDDF: bbox_eddf<- c(xmin = 7.536746, xmax = 9.604390, ymin = 49.36732, ymax = 50.69920)
# EIDW: 
# bbox_eidw <- determine_bbox("EIDW", 50)
bbox_eidw<- c(xmin =-7.667338, xmax =-4.872812, ymin = 52.58856, ymax = 54.2541)
bbox <- bbox_eidw

############### OPEN SESSION #######################################
# Losvce1300
# from home skip host, etc
# session <- osn_connect("espin")
# from work
# 1. go to putty, 2. select / load magic and add password
# session <- osn_connect("espin", host = "localhost", port = 6666)

print(session)

############## DEFINE TIMEFRAME ####################################

horizon <- seq(
    as.POSIXct("2019-05-06 00:00:00",tz="UTC")  # start date
  , as.POSIXct("2019-05-19 23:00:00",tz="UTC")  # horizon end date 23:00hrs
  , by="hour")

############## ITERATE AND DOWNLOAD ###############################

horizon %>% purrr::walk(.f=~query_osn(., .session=session, .bbox = bbox))

############### CLOSE SESSION WHEN DONE ###########################

osn::osn_disconnect(session)
