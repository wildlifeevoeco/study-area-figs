### Newfoundland prep ====
# Alec L. Robitaille


### Packages ----
libs <- c('sf',
					'osmdata')
lapply(libs, require, character.only = TRUE)

### Download OSM data ----
# Download osm coastlines in bbox
# NOTE: This steps takes a few moments
zz <- opq(getbb('Newfoundland')) %>%
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
st_write(utmNL, 'output/newfoundland-polygons.gpkg')
