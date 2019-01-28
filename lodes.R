# Author: Geoffrey Arnold

# Packages
require(tidyverse)
require(tidycensus)
require(lehdr)
require(jsonlite)

require(rgdal)
require(leaflet)

keys <- fromJSON("key.json")
census_api_key(keys$census, install = T)

aco_tracts <- readOGR("http://openac-alcogis.opendata.arcgis.com/datasets/31a3233d728549458e68cb02cb5bc9bb_0.geojson")

pa <- grab_lodes("pa", year = 2015, lodes_type = "wac", segment = "S000", agg_geo = "tract")
alco <- filter(pa, w_tract %in% aco_tracts$GEOID)

acs <- get_acs("tract", variables = "DP05_0001E", year = 2016, survey = "acs5", state = "PA", county = "03") %>%
  rename(totalpop = estimate,
         totalpop_moe = moe)

aco_lodes <- merge(aco_tracts, alco, by.x = "GEOID", by.y = "w_tract", all.x = TRUE)
aco_all <- merge(aco_lodes, acs, by = "GEOID", all.x = TRUE)

# data_fix <- aco_all@data %>%
#   select(GEOID, totalpop, C000) %>%
#   rename(workpop = C000) %>%
#   reshape2::melt("GEOID") %>%
#   mutate(variable = as.factor(variable))

leaflet(data = aco_all) %>%
  addPolygons()

