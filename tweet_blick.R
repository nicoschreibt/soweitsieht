require('newsmap')
require('quanteda')
require('maps')
require('tidyverse')
require('twitteR')
require('stringr')
require('filesstrings')
setwd("/home/pi/R/projects")
datum <- format(Sys.Date(),"%d_%b_%Y")
datum_blick <- paste0("blick_",datum)
datum_leerschlag <- format(Sys.Date(),"%d %b %Y")
account <- "nicolas.saameli@stud.unilu.ch"
passwort <- "seetheworld"
ckey <- "zr8mWNvmSzzMlEWDdOqmkccHj"
csecret <- "fIgvRIIi4dRYHtd33OQ8CVauh6hJy8ieX1Lm1PKTU6b5zHdPvB"
atoken <- "1268106017457483776-XoopnGcv6oC7sjm3UWdLkZl03Yj7kv"
asecret <- "b8rVr0ytn7JfHCge8hNJV5QXS02MNeDA4XafzFPBNBdrV"
setup_twitter_oauth(ckey, csecret, atoken, asecret)
2
df_blick <-
  list.files(path = "/home/pi/R/projects", pattern= datum_blick) %>% 
  map_df(~read_csv(.))
df_blick <- df_blick[!duplicated(df_blick$URL),]
df_blick$datumdmy <- str_sub(df_blick$Zeit, 12, 22)
df_blick$datumdmy
df_blick$datumdmy <- lubridate::dmy(df_blick$datumdmy)%>%
  format("%d %b %Y")
df_blick <- df_blick %>%
  filter(datumdmy == datum_leerschlag)
korpus_blick <- corpus(df_blick,text_field = "Text")
tokens_blick <- tokens(korpus_blick)%>%
  tokens_tolower()
dfm_blick <- dfm(tokens_blick)
dfm_lookup(dfm_blick,dictionary = data_dictionary_newsmap_de, levels = 3)
nennungen_blick <- tokens_lookup(tokens_blick, dictionary = data_dictionary_newsmap_de, levels = 3)
nennungen_blick_dfm <- dfm(nennungen_blick) %>%
  dfm_trim(min_termfreq = 1)
df_blick <- convert(nennungen_blick_dfm, to = "data.frame")
df_blick <- df_blick[,-1]
df_blick_summen <- data.frame(colSums(df_blick))
df_blick_summen$id <-rownames(df_blick_summen) %>%
  toupper()
names(df_blick_summen)[names(df_blick_summen) == "colSums.df_blick."] <- "frequenz"
world_map <- map_data(map = "world")
world_map$region <- iso.alpha(world_map$region)
ggplot(df_blick_summen, aes(map_id = id)) +
  geom_map(aes(fill = frequenz), map = world_map, show.legend = FALSE, colour = "grey") +
  expand_limits(x = world_map$long, y = world_map$lat) +
  scale_fill_gradient(high="red", low = "white") +
  theme_void() +
  coord_fixed()
ggsave(filename = "blick.png", device = "png")
tweet(text = paste0("#Blick am ", format(Sys.Date(),"%d.%m.%Y"),"."), mediaPath = "/home/pi/R/projects/blick.png")