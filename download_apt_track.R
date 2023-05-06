# inspiration from https://www.tylermw.com/loading-and-visualizing-opensky-network-data-in-r/

library(tidyverse) 
library(httr) 
library(jsonlite)
library(glue)

username = Sys.getenv("osn_usr")
password = Sys.getenv("osn_pw")

apt = "EDDF"
dof = "2020-08-10"

tracklist = list()
counter_tracks = 1

#This is the string we'll use to access the departures API
# path = glue("https://{username}:{password}@opensky-network.org/api/flights/departure?")
path = glue("https://{username}:{password}@opensky-network.org/api/flights/arrival?")


#This is the string we'll use to access the tracks API
trackpath = glue("https://{username}:{password}@opensky-network.org/api/tracks/all?")

for(j in 1:23) {
  begintime = as.numeric(as.POSIXct(sprintf("2020-08-10 %0.2d:00:00 UTC",j-1)))
  endtime = as.numeric(as.POSIXct(sprintf("2020-08-10 %0.2d:00:00 UTC",j)))
  #begintime = as.numeric(as.POSIXct(sprintf(paste0(dof," %0.2d:01:00 EST",j-1))))
  
  
  #Get the flights departing within that hour
  request = GET(url = path, 
                query = list(
                  airport = apt,
                  begin = begintime,
                  end = endtime))
  response = content(request, as = "text", encoding = "UTF-8")
  df = data.frame(fromJSON(response, flatten = TRUE))
  
  #Read the actual tracks
  # for(i in 1:nrow(df)) {
  #   request_track = GET(url = trackpath, 
  #                       query = list(
  #                         icao24 = df$icao24[i],
  #                         time = begintime+1800)) #Offset to the middle of the hour
  #   
  #   response_track = content(request_track, as = "text", encoding = "UTF-8")
  #   if(response_track != "") {
  #     tracklist[[counter_tracks]] = data.frame(fromJSON(response_track, flatten = TRUE))
  #   }
  #   counter_tracks = counter_tracks + 1
  # }
}