library(dplyr)
library(ggplot2)
library(forcats)

ukchart <- readRDS('ukchartTidy.rds')
uschart <- readRDS('uschartTidy.rds')

##### count of chartweeks and sum of points
uschart.count <- count(uschart, artist.simple, title)
uschart.artist.count <- setNames(count(uschart, artist.simple),c('artist','uschartweeks'))
uschart.artist.count <- merge(uschart.artist.count, setNames(aggregate(uschart$points, by = list(uschart$artist.simple), FUN = sum),c('artist','uschartpoints')))

ukchart.count <- count(ukchart, artist.simple, title)
ukchart.artist.count <- setNames(count(ukchart, artist.simple), c('artist', 'ukchartweeks'))
ukchart.artist.count <- merge(ukchart.artist.count, setNames(aggregate(ukchart$points, by = list(ukchart$artist.simple), FUN = sum),c('artist','ukchartpoints')))


##### merge the UK and US
allchart <- merge(ukchart.artist.count, uschart.artist.count, all = TRUE)
allchart$ukchartweeks[is.na(allchart$ukchartweeks)] <- 0
allchart$uschartweeks[is.na(allchart$uschartweeks)] <- 0
allchart$ukchartpoints[is.na(allchart$ukchartpoints)] <- 0
allchart$uschartpoints[is.na(allchart$uschartpoints)] <- 0
allchart$weekabsvar <- abs(allchart$ukchartweeks - allchart$uschartweeks)
allchart$weekvar <- allchart$ukchartweeks - allchart$uschartweeks
allchart$pointsabsvar <- abs(allchart$ukchartpoints - allchart$uschartpoints)

# variable for which is more popular
allchart$preference[allchart$weekvar < 0] <- 'US'
allchart$preference[allchart$weekvar == 0] <- 'Same'
allchart$preference[allchart$weekvar > 0] <- 'UK'

##### graph the bugger up
allchart <- allchart %>% 
  mutate(rank = rank(-weekabsvar))

allchart.filter <- filter(allchart, rank <= 20)

ggplot(allchart.filter, aes(fct_reorder(artist, -rank), weekvar)) +
  geom_col(aes(fill = preference)) + 
  theme_classic() +
  coord_flip() + 
  labs(title = 'Chart Differences Between The UK & US', subtitle = 'Top 50s Since 1960-03-11', caption = 'Sources: www.billboard.com & www.officialcharts.com') +
  ylab(paste('Difference in Total Chart Weeks')) + 
  scale_fill_manual(values=c("red", "blue", "green")) + 
  theme(legend.position='bottom',
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        plot.title = element_text(hjust = 0.5, size = 24),
        plot.subtitle = element_text(hjust = 0.5, size = 16),
        axis.title = element_text(size = 16),
        axis.title.y =  element_blank()
  )
