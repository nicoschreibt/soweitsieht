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
account <- "nicolas.saameli@stud.unilu.ch"
passwort <- "seetheworld"
ckey <- "zr8mWNvmSzzMlEWDdOqmkccHj"
csecret <- "fIgvRIIi4dRYHtd33OQ8CVauh6hJy8ieX1Lm1PKTU6b5zHdPvB"
atoken <- "1268106017457483776-XoopnGcv6oC7sjm3UWdLkZl03Yj7kv"
asecret <- "b8rVr0ytn7JfHCge8hNJV5QXS02MNeDA4XafzFPBNBdrV"
setup_twitter_oauth(ckey, csecret, atoken, asecret)
2
datum_srf <- paste0("srf_",datum)
df_srf <-
  list.files(path = "/home/pi/R/projects", pattern= datum_srf) %>% 
  map_df(~read_csv(.))
df_srf$datumdmy <- str_sub(df_srf$Zeit, 6, 16)
df_srf <- df_srf[!duplicated(df_srf$URL),]
df_srf$datumdmy <- lubridate::dmy(df_srf$datumdmy)%>%
  format("%d %b %Y")
df_srf <- df_srf %>%
  filter(datumdmy == datum_leerschlag)
korpus_srf <- corpus(df_srf,text_field = "Text")
tokens_srf <- tokens(korpus_srf)%>%
  tokens_tolower()
dfm_srf <- dfm(tokens_srf)
dfm_lookup(dfm_srf,dictionary = data_dictionary_newsmap_de, levels = 3)
nennungen_srf <- tokens_lookup(tokens_srf, dictionary = data_dictionary_newsmap_de, levels = 3)
nennungen_srf_dfm <- dfm(nennungen_srf) %>%
  dfm_trim(min_termfreq = 1)
df_srf <- convert(nennungen_srf_dfm, to = "data.frame")
df_srf <- df_srf[,-1]
df_srf_summen <- data.frame(colSums(df_srf))
df_srf_summen$id <-rownames(df_srf_summen) %>%
  toupper()
names(df_srf_summen)[names(df_srf_summen) == "colSums.df_srf."] <- "frequenz"
world_map <- map_data(map = "world")
world_map$region <- iso.alpha(world_map$region)
ggplot(df_srf_summen, aes(map_id = id)) +
  geom_map(aes(fill = frequenz), map = world_map, show.legend = FALSE, colour = "grey") +
  expand_limits(x = world_map$long, y = world_map$lat) +
  scale_fill_gradient(name = "Nennungen", high="red", low = "white") +
  theme_void() +
  coord_fixed()
ggsave(filename = "srf.png", device = "png")
tweet(text = paste0("#SRFnews am ", format(Sys.Date(),"%d.%m.%Y"),"."), mediaPath = "/home/pi/R/projects/srf.png")