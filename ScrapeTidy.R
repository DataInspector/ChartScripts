library(dplyr)
library(rvest)
library(stringr)


##### load and tidy data
uschart <- readRDS('uschart.rds')
ukchart <- readRDS('ukchart.rds')
uschart$rank <- as.numeric(uschart$rank)
ukchart$rank <- as.numeric(ukchart$rank)
uschart$title <- as.character(uschart$title)
ukchart$title <- as.character(ukchart$title)
uschart$artist <- as.character(uschart$artist)
ukchart$artist <- as.character(ukchart$artist)
uschart$artist <- str_to_upper(uschart$artist) # UK charts are in upper case so changing US to match
uschart$title <- str_to_upper(uschart$title) # UK charts are in upper case so changing US to match

# filter to start from a common point when the UK charts started. Pulling 50 places not the full US 100 as at the beginning the UK only had 50
uschart <- filter(uschart, date >= '1960-03-11', rank <= 50)
ukchart <- filter(ukchart, date >= '1960-03-11', rank <= 50)

# create rank points
uschart$points <- 50 - uschart$rank
ukchart$points <- 50 - ukchart$rank

# ensure most popular artists have common names between US and UK
ukchart$artist[ukchart$artist == 'PINK'] <- 'P!NK'
ukchart$artist[ukchart$artist == 'R KELLY'] <- 'R. KELLY'
ukchart$artist[ukchart$artist == 'BLACK EYED PEAS']<- 'THE BLACK EYED PEAS'
ukchart$artist[ukchart$artist == 'THE BEE GEES'] <- 'BEE GEES'
ukchart$artist[ukchart$artist == 'THE FOUR TOPS'] <- 'FOUR TOPS'
ukchart$artist[ukchart$artist == 'MARY J BLIGE'] <- 'MARY J. BLIGE'
uschart$artist[uschart$artist == 'DARYL HALL JOHN OATES'] <- 'DARYL HALL AND JOHN OATES'

# simplify artist names to remove 'Featuring' 'Feat' and 'With The'
uschart$artist.temp <- as.numeric(regexpr(' FEAT', uschart$artist))
uschart$artist.temp[uschart$artist.temp==-1] <- as.numeric(regexpr(' WITH THE', uschart$artist[uschart$artist.temp==-1]))
uschart$artist.temp[uschart$artist.temp<0] <- 100 # set the string length to 100 where 'FEAT' or 'WITH THE' isn't found so it isn't trimmed
uschart$artist.simple <- as.character(str_sub(uschart$artist, 1, uschart$artist.temp-1))

ukchart$artist.temp <- as.numeric(regexpr(' FT', ukchart$artist))
ukchart$artist.temp[ukchart$artist.temp<0] <- 100 # set the string length to 100 where 'FT' isn't found so it isn't trimmed
ukchart$artist.simple <- as.character(str_sub(ukchart$artist, 1, ukchart$artist.temp-1)) #


# save the tidier data
saveRDS(ukchart, 'ukchartTidy.rds')
saveRDS(uschart, 'uschartTidy.rds')
