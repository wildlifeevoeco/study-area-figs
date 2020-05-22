### Middle Ridge prep ====
# Alec L. Robitaille


### Packages ----
libs <- c('sf', 'osmdata')
lapply(libs, require, character.only = TRUE)

### Download OSM data ----
# Download osm coastlines in bbox
# NOTE: This steps takes a few moments
zz <- opq(c(-55.58, 47.61, -54.32, 49.11)) %>%
	# add_osm_feature(key = 'place', value = 'island') %>%
	osmdata_sf()


# Download water
watercall <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = 'water') %>%
	osmdata_sf()

# Download forest
forestcall <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = c('forest', 'wood')) %>%
	osmdata_sf()

# Trails and roads
roadscall <- opq(bb) %>%
	add_osm_feature(key = 'highway') %>% # , value = c('forest', 'wood')) %>%
	osmdata_sf()
