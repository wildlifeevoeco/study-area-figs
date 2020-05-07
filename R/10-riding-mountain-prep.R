### Riding Mountain - Prep ====
# Alec L. Robitaille


### Packages ----
libs <- c('sf', 'osmdata', 'fasterize')
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
utm <- st_crs(32614)

# Combine water polygons into a raster
wpolys <- st_transform(water$osm_polygons, utm)
wmpolys <- st_transform(water$osm_multipolygons, utm)

# Note: fasterize still needs to update to use the new sf crs
# 	in the meantime, install with devtools::install_github('ecohealthalliance/fasterize', ref ='2efaa974684b3abdc945274292c84759a7116f5c')
res <- 30
w <- st_as_sf(st_combine(wpolys))
r <- raster(wpolys, resolution = res)
fw <- fasterize(w, r)

wm <- st_as_sf(st_combine(wmpolys))
rm <- raster(wmpolys, resolution = res)
fwm <- fasterize(wm, r)

waterRaster <- fwm | fw

## Combine forests

fpolys <- st_buffer(st_combine(forest$osm_polygons), 0)
fmpolys <- st_combine(forest$osm_multipolygons), 0)
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
