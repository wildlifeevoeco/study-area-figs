### Riding Mountain - Prep ====
# Alec L. Robitaille


### Packages ----
libs <- c('sf', 'osmdata')
lapply(libs, require, character.only = TRUE)

### Download OSM data ----
library(mapview)

# Bounding box (min xy, max xy)
bb <- c(-101.1758, 50.3244, -99.4016, 51.1811)

# Download RMNP bounds
boundscall <- opq(bb) %>%
	add_osm_feature(key = 'name', value = 'Riding Mountain National Park') %>%
	osmdata_sf()

bounds <- boundscall$osm_polygons

# Download water
water <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = 'water') %>%
	osmdata_sf()


# Download forest
forest <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = c('forest', 'wood')) %>%
	osmdata_sf()

### Prep geometries ----
# Combine waters
wpolys <- st_buffer(st_combine(water$osm_polygons), 0)
wmpolys <- st_combine(water$osm_multipolygons)
waterpolys <- st_union(wpolys, wmpolys)

waterlns <- st_combine(water$osm_lines)

## Combine forests
# Combine waters
fpolys <- st_combine(forest$osm_polygons)
fmpolys <- st_combine(forest$osm_multipolygons)
forestpolys <- st_union(fpolys, fmpolys)

# forestlns <- st_combine(forest$osm_lines)

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
