# === Riding Mountain - Prep ----------------------------------------------
# Alec L. Robitaille



# Packages ----------------------------------------------------------------
libs <- c('sf', 'osmdata', 'raster')
lapply(libs, require, character.only = TRUE)



# Download OSM data -------------------------------------------------------
# Bounding box (min xy, max xy)
bb <- c(-101.26, 50.16, -99.14, 51.50)

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


# Prep geometries ---------------------------------------------------------
utm <- st_crs(32614)

## Combine water polygons
# Transform to UTM
wpolys <- st_transform(watercall$osm_polygons, utm)
wmpolys <- st_transform(watercall$osm_multipolygons, utm)

# Calculate area
wpolys$area <- st_area(wpolys)
wmpolys$area <- st_area(wmpolys)

thresharea <- quantile(wpolys$area, .70)

w <- st_as_sf(st_combine(wpolys[wpolys$area > thresharea,]))
wm <- st_as_sf(st_combine(wmpolys[wmpolys$area > thresharea,]))

water <- st_union(st_make_valid(w), wm)

## Combine forest polygons
fmpolys <- st_transform(forestcall$osm_multipolygons, utm)

forest <- st_as_sf(st_combine(st_simplify(fmpolys)))

# Reproject
boundutm <- st_transform(bounds, utm)
roadutm <- st_transform(roadscall$osm_lines, utm)



# Output ------------------------------------------------------------------
st_write(boundutm, 'output/rmnp-bounds.gpkg')
st_write(roadutm, 'output/rmnp-roads.gpkg')
st_write(forest, 'output/rmnp-forest.gpkg')
st_write(water, 'output/rmnp-water.gpkg')
