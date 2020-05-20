### Riding Mountain - Prep ====
# Alec L. Robitaille


### Packages ----
libs <- c('sf', 'osmdata', 'fasterize', 'raster', 'rnaturalearth')
lapply(libs, require, character.only = TRUE)

### Download OSM data ----
library(mapview)


lakes <- rnaturalearth::ne_download(
	scale = 'large',
	type = 'lakes',
	category = 'physical',
	returnclass = 'sf'
)


# Bounding box (min xy, max xy)
bb <- c(-101.1758, 50.3244, -99.4016, 51.1811)

# Download RMNP bounds
boundscall <- opq(bb) %>%
	add_osm_feature(key = 'name', value = 'Riding Mountain National Park') %>%
	osmdata_sf()

bounds <- boundscall$osm_polygons

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

### Prep geometries ----
utm <- st_crs(32614)

## Combine water polygons into a raster
# Transform to UTM
wpolys <- st_transform(watercall$osm_polygons, utm)
wmpolys <- st_transform(watercall$osm_multipolygons, utm)

# Calculate area
wpolys$area <- st_area(wpolys)
wmpolys$area <- st_area(wmpolys)

thresharea <- quantile(wpolys$area, .70)

w <- st_as_sf(st_combine(wpolys[wpolys$area > thresharea,]))
wm <- st_as_sf(st_combine(wmpolys[wmpolys$area > thresharea,]))

# Note: fasterize still needs to update to use the new sf crs
# 	in the meantime, install with devtools::install_github('ecohealthalliance/fasterize', ref ='2efaa974684b3abdc945274292c84759a7116f5c')
res <- 250
r <- raster(wpolys, resolution = res)
fw <- fasterize(w, r)

rm <- raster(wmpolys, resolution = res)
fwm <- fasterize(wm, r)

waterRaster <- fwm | fw

plot(waterRaster, main = 'even larger')

## Combine forest polygons into a raster
fpolys <- st_transform(forest$osm_polygons, utm)
fmpolys <- st_transform(forest$osm_multipolygons, utm)

f <- st_as_sf(st_combine(fpolys))
rf <- raster(fmpolys, resolution = res)
ff <- fasterize(f, rf)

fm <- st_as_sf(st_combine(fmpolys))
# rfm <- raster(fmpolys, resolution = res)
ffm <- fasterize(fm, rf)

forestRaster <- ff | ffm


### Reproject ----
bound <- st_transform(bounds, utm)
road <- st_transform(roads$osm_lines, utm)

### Output ----
st_write(bounds, 'output/rmnp-bounds.gpkg')
st_write(road, 'output/rmnp-roads.gpkg')

writeRaster(waterRaster, 'output/rmnp-water.tif')
writeRaster(forestRaster, 'output/rmnp-forest.tif')
