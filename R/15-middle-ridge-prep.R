### Middle Ridge prep ====
# Alec L. Robitaille


### Packages ----
libs <- c('sf', 'osmdata')
lapply(libs, require, character.only = TRUE)

### Download OSM data ----
# Download osm coastlines in bbox
# NOTE: This steps takes a few moments
bb <- c(-55.58, 47.76, -54.52, 48.55)

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
	add_osm_feature(key = 'highway') %>%
	osmdata_sf()


