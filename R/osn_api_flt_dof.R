dof   <- "2019-05-20" 
slots <- 0:23
slots <- sprintf("%02d",slots)
slots <- paste0(dof, " ", slots, ":00:00")
#slots

rq <- slots %>% purrr::map_dfr(.f = ~ osn_api_flt(.apt = "EDDF", .type = "arrival", .start = .x)))