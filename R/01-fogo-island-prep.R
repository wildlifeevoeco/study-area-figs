### Fogo island prep ====
# Alec L. Robitaille


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
zz <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = 'coastline') %>%
	osmdata_sf()

# Grab polygons (small islands)
polys <- zz$osm_polygons

# Grab lines (large islands including Fogo)
lns <- zz$osm_lines

# Union -> polygonize -> cast lines = geo set
castpolys <- st_cast(st_polygonize(st_union(lns)))

# Combine geometries and cast as sf
islands <- st_as_sf(c(st_geometry(polys), castpolys))

# Basic island id
islands$id <- seq.int(length.out = nrow(islands))


### Reproject islands ----
# Projections
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')

# Project to UTM
utmislands <- st_transform(islands, utm)


### Output ----
saveRDS(utmislands, "output/fogo-island-polygons.Rds")

