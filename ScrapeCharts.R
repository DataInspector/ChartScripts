library(rvest)

##### US charts #####

# create dateframe and empty version
usdates <- data.frame(dates = seq(as.Date('1958-08-04'), length = 3218, by = 'weeks'))
uschart <- data.frame()

# loop through ever week from billboard
for (i in 1:nrow(usdates)) {
  usurl <- paste0('https://www.billboard.com/charts/hot-100/',usdates[i,1],'/')
  ushtml_data <- read_html(usurl)
  usrank <- ushtml_data %>% html_nodes('span.chart-element__rank__number') %>% html_text()
  ustitle <- ushtml_data %>% html_nodes('span.chart-element__information__song') %>% html_text()
  usartist <- ushtml_data %>% html_nodes('span.chart-element__information__artist') %>% html_text()
  temp <- data.frame(date = usdates[i,1],rank = usrank, title = ustitle, artist = usartist)
  uschart <- rbind(uschart, temp)
  print(i)
  Sys.sleep(6) # required as there is an anti-scrape lockout of between 5 an 6 seconds
  closeAllConnections()
}

saveRDS(uschart, 'uschart.rds')
rm(temp, usdates, i, usartist, ushtml_data, usrank, ustitle, usurl)


##### UK charts #####

# create dateframe and empty version
ukdates <- data.frame(dates = seq(as.Date('1958-08-08'), length = 3217, by = 'weeks'))
ukchart <- data.frame()

# loop through ever week from officialcharts
for (i in 821:nrow(ukdates)) {
  ukurl <- paste0('https://www.officialcharts.com/charts/singles-chart/',format(ukdates[i,1],'%Y%m%d'),'/7501/')
  ukhtml_data <- read_html(ukurl)
  ukrank <- ukhtml_data %>% html_nodes('span.position') %>% html_text()
  uktitle <- ukhtml_data %>% html_nodes('div.title') %>% html_text()
  ukartist <- ukhtml_data %>% html_nodes('div.artist') %>% html_text()
  uktitle <- trimws(gsub('\r\n','',uktitle))
  ukartist <- trimws(gsub('\r\n','',ukartist))
  temp <- data.frame(date = ukdates[i,1],rank = ukrank, title = uktitle, artist = ukartist)
  ukchart <- rbind(ukchart, temp)
  print(i)
  Sys.sleep(1)
  closeAllConnections()
}

saveRDS(ukchart, 'ukchart.rds')
rm(temp, ukdates, i, ukartist, ukhtml_data, ukrank, uktitle, ukurl)

