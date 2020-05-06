### Riding Mountain - Prep ====
# Alec L. Robitaille


### Packages ----
libs <- c('sf', 'osmdata')
lapply(libs, require, character.only = TRUE)

### Download OSM data ----
library(mapview)

# Download RMNP bounds
bb <- c(-101.1758, 50.6216, -99.4016, 51.1811)
# zz <- opq(getbb('Riding Mountain National Park')) %>%
bounds <- opq() %>%
	add_osm_feature(key = 'name', value = 'Riding Mountain National Park') %>%
osmdata_sf()$osm_polygons

zzz <- opq(c(-101.1758, 50.6216, -99.4016, 51.1811)) %>%
	add_osm_feature(key = 'name', value = 'Riding Mountain National Park')
	# add_osm_feature(key = 'boundary', value = 'national_park') %>%
	osmdata_sf()

zz


# # Grab lines
# lns <- zz$osm_lines
#
# # Union -> polygonize -> cast lines = geometry set
# castpolys <- st_cast(st_polygonize(st_union(lns)))
#
# # Combine geometries and cast as sf
# nl <- st_as_sf(castpolys)
#
#
# ### Reproject islands ----
# # Projections
# utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')
#
# # Project to UTM
# utmNL <- st_transform(nl, utm)
#
#
# ### Output ----
# st_write(utmNL, 'output/newfoundland-polygons.gpkg')
