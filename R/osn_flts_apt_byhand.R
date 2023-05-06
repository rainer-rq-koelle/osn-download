rq <- list()

rq[[1]] <- extract_flt_apt("LSZH", .type = "arrival",  .from = "2019-10-01 00:00:00", .to = "2019-10-07 23:59:59", .login = Sys.getenv("osn_usr"), .password = Sys.getenv("osn_pw"))
rq[[2]] <- extract_flt_apt("LSZH", .type = "arrival",  .from = "2019-10-08 00:00:00", .to = "2019-10-14 23:59:59", .login = Sys.getenv("osn_usr"), .password = Sys.getenv("osn_pw"))
rq[[3]] <- extract_flt_apt("LSZH", .type = "arrival",  .from = "2019-10-15 00:00:00", .to = "2019-10-21 23:59:59", .login = Sys.getenv("osn_usr"), .password = Sys.getenv("osn_pw"))
rq[[4]] <- extract_flt_apt("LSZH", .type = "arrival",  .from = "2019-10-22 00:00:00", .to = "2019-10-26 23:59:59", .login = Sys.getenv("osn_usr"), .password = Sys.getenv("osn_pw"))
rq[[5]] <- extract_flt_apt("LSZH", .type = "arrival",  .from = "2019-10-29 00:00:00", .to = "2019-10-31 23:59:59", .login = Sys.getenv("osn_usr"), .password = Sys.getenv("osn_pw"))
rq[[6]] <- extract_flt_apt("LSZH", .type = "departure",.from = "2019-10-01 00:00:00", .to = "2019-10-07 23:59:59", .login = Sys.getenv("osn_usr"), .password = Sys.getenv("osn_pw"))
rq[[7]] <- extract_flt_apt("LSZH", .type = "departure",.from = "2019-10-08 00:00:00", .to = "2019-10-14 23:59:59", .login = Sys.getenv("osn_usr"), .password = Sys.getenv("osn_pw"))
rq[[8]] <- extract_flt_apt("LSZH", .type = "departure",.from = "2019-10-15 00:00:00", .to = "2019-10-21 23:59:59", .login = Sys.getenv("osn_usr"), .password = Sys.getenv("osn_pw"))
rq[[9]] <- extract_flt_apt("LSZH", .type = "departure",.from = "2019-10-22 00:00:00", .to = "2019-10-26 23:59:59", .login = Sys.getenv("osn_usr"), .password = Sys.getenv("osn_pw"))
rq[[10]]<- extract_flt_apt("LSZH", .type = "departure",.from = "2019-10-29 00:00:00", .to = "2019-10-31 23:59:59", .login = Sys.getenv("osn_usr"), .password = Sys.getenv("osn_pw"))

rq %>% bind_rows() %>% write_csv("./data/osn_LSZH_api_2019-10.csv")
