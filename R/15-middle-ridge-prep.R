# === Middle Ridge - Prep -------------------------------------------------
# Alec L. Robitaille



# Packages ----------------------------------------------------------------
libs <- c('curl', 'sf', 'osmdata')
lapply(libs, require, character.only = TRUE)



# Download Open Gov data --------------------------------------------------
#
curl_download('https://www.gov.nl.ca/ecc/files/natural-areas-provincialprotectedareasnl.zip', 'input/newfoundland-protected-areas.zip')
dir.create('input')
unzip('input/newfoundland-protected-areas.zip', exdir = 'input/newfoundland-protected-areas')

areas <- st_read('input/newfoundland-protected-areas')

subareas <- areas[areas$NAME_E %in% c('Middle Ridge Wildlife Reserve',
																			'Bay du Nord Wilderness Reserve'),]


# Download OSM data -------------------------------------------------------
# Download osm coastlines in bbox
# NOTE: This steps takes a few moments
areabb <- st_bbox(st_buffer(subareas, 0.7))
bb <- c(areabb['xmin'], areabb['ymin'], areabb['xmax'], areabb['ymax'])

# Download water
# watercall <- opq(bb) %>%
# 	add_osm_feature(key = 'natural', value = 'water') %>%
# 	osmdata_sf()

# Download forest
# forestcall <- opq(bb) %>%
# 	add_osm_feature(key = 'natural', value = c('forest', 'wood')) %>%
# 	osmdata_sf()

# Trails and roads
roadscall <- opq(bb) %>%
	add_osm_feature(key = 'highway') %>%
	osmdata_sf()



# Prep geometries ---------------------------------------------------------
utm <- st_crs(32621)

## Combine water polygons
# Transform to UTM
# wpolys <- st_transform(watercall$osm_polygons, utm)
# wmpolys <- st_transform(watercall$osm_multipolygons, utm)
#
# # Calculate area
# wpolys$area <- st_area(wpolys)
# wmpolys$area <- st_area(wmpolys)
#
# thresharea <- quantile(wpolys$area, .95)
#
# w <- st_as_sf(st_combine(wpolys[wpolys$area > thresharea,]))
# wm <- st_as_sf(st_combine(wmpolys[wmpolys$area > thresharea,]))
#
# water <- st_union(w, wm)

## Combine forest polygons
# fmpolys <- st_transform(forestcall$osm_multipolygons, utm)
#
# forest <- st_as_sf(st_combine(st_simplify(fmpolys)))

## Bounds
# bounds <- st_as_sfc(st_bbox(c(xmin = bb[1], xmax = bb[3], ymin = bb[2], ymax = bb[4]), crs = st_crs(4326)))

## Reproject
roadutm <- st_transform(roadscall$osm_lines, utm)
# boundutm <- st_transform(bounds, utm)
areasutm <- st_transform(subareas, utm)

# Output ------------------------------------------------------------------
# st_write(boundutm, 'output/mr-bounds.gpkg')
st_write(roadutm, 'output/mr-roads.gpkg', append = FALSE)
st_write(areasutm, 'output/mr-protected-areas.gpkg')
# st_write(forest, 'output/mr-forest.gpkg')
# st_write(water, 'output/mr-water.gpkg')

