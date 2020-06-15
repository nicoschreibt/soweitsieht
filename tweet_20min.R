require('newsmap')
require('quanteda')
require('maps')
require('tidyverse')
require('twitteR')
require('stringr')
require('filesstrings')
setwd("/home/pi/R/projects")
datum <- format(Sys.Date(),"%d_%b_%Y")
datum_leerschlag <- format(Sys.Date(),"%d %b %Y")
ckey <- "xxx"
csecret <- "xxx"
atoken <- "xxx"
asecret <- "xxx"
setup_twitter_oauth(ckey, csecret, atoken, asecret)
2
datum_20min <- paste0("20min_",datum)
df_20min <-
  list.files(path = "/home/pi/R/projects", pattern= datum_20min) %>% 
  map_df(~read_csv(.))
df_20min <- df_20min[!duplicated(df_20min$URL),]
df_20min$datumdmy <- str_sub(df_20min$Zeit, 0, 10)
datum_lubridate <- lubridate::ymd(df_20min$datumdmy)%>%
  format("%d %b %Y")
df_20min$datumdmy <- datum_lubridate
datum_leerschlag <- format(Sys.Date(),"%d %b %Y")
df_20min <- df_20min %>%
  filter(datumdmy == datum_leerschlag)
korpus <- corpus(df_20min,text_field = "Text")
tokens_20min <- tokens(korpus)%>%
  tokens_tolower()
dfm_20min <- dfm(tokens_20min)
dfm_lookup(dfm_20min,dictionary = data_dictionary_newsmap_de, levels = 3)
nennungen_20min <- tokens_lookup(tokens_20min, dictionary = data_dictionary_newsmap_de, levels = 3)
nennungen_20min_dfm <- dfm(nennungen_20min) %>%
  dfm_trim(min_termfreq = 1)
nennungen_20min_dfm_ungetrimt <- dfm(nennungen_20min)
df_20min <- convert(nennungen_20min_dfm, to = "data.frame")
df_20min <- df_20min[,-1]
df_20min_summen <- data.frame(colSums(df_20min))
df_20min_summen$id <-rownames(df_20min_summen) %>%
  toupper()
names(df_20min_summen)[names(df_20min_summen) == "colSums.df_20min."] <- "frequenz"
world_map <- map_data(map = "world")
world_map$region <- iso.alpha(world_map$region)
ggplot(df_20min_summen, aes(map_id = id)) +
  geom_map(aes(fill = frequenz), map = world_map, show.legend = FALSE, colour = "grey") +
  expand_limits(x = world_map$long, y = world_map$lat) +
  scale_fill_gradient(name = "Nennungen", high="red", low = "white") +
  theme_void() +
  coord_fixed()
ggsave(filename = "20min.png", device = "png")
tweet(text = paste0("#20Minuten am ", format(Sys.Date(),"%d.%m.%Y"),"."), mediaPath = "/home/pi/R/projects/20min.png")
