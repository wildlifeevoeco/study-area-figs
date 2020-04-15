### Terra Nova prep ====
# Alec L. Robitaille, Isabella Richmond


### Packages ----
libs <- c('sf',
					'osmdata')
lapply(libs, require, character.only = TRUE)

### Download OSM data ----
# Set up bounding box - order: xmin, ymin, xmax, ymax
bb <- c(xmin = -54.3533,
				ymin = 49.5194,
				xmax = -53.954220,
				ymax = 49.763834)

# Download osm coastlines in bbox
# NOTE: This steps takes a few moments
zz <- opq(getbb("Newfoundland")) %>%
	add_osm_feature(key = 'place', value = 'island') %>%
	osmdata_sf()

# Grab lines
lns <- zz$osm_lines

# Union -> polygonize -> cast lines = geometry set
castpolys <- st_cast(st_polygonize(st_union(lns)))

# Combine geometries and cast as sf
nl <- st_as_sf(castpolys)


### Reproject islands ----
# Projections
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')

# Project to UTM
utmNL <- st_transform(nl, utm)


### Output ----
saveRDS(utmNL, "output/newfoundland-polygons.Rds")
