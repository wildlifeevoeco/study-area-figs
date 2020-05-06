### Riding Mountain - Prep ====
# Alec L. Robitaille


### Packages ----
libs <- c('sf', 'osmdata')
lapply(libs, require, character.only = TRUE)

### Download OSM data ----
library(mapview)

# Bounding box (min xy, max xy)
bb <- c(-101.1758, 50.6216, -99.4016, 51.1811)

# Download RMNP bounds
boundscall <- opq(bb) %>%
	add_osm_feature(key = 'name', value = 'Riding Mountain National Park') %>%
	osmdata_sf()

bounds <- boundscall$osm_polygons

# Download water
water <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = 'water') %>%
	osmdata_sf()

waterlns <- st_combine(water$osm_lines)
waterpols <- st_combine(water$osm_polygons)
watermpolys <- st_combine(water$osm_multipolygons)

rbind(waterpolys, watermpolys)

forest <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = 'wood') %>%
	osmdata_sf()

waterlns[which(colnames(waterlns) %in% c('osm_id', 'geometry')),]
colnames(waterlns)

plot(waterlns)
plot(waterpols)

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
