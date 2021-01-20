# === Fogo Island Prep ----------------------------------------------------
# Alec L. Robitaille


# Packages ----------------------------------------------------------------
libs <- c('sf',
					'osmdata')
lapply(libs, require, character.only = TRUE)



# Download OSM data -------------------------------------------------------
# Set up bounding box - order: xmin, ymin, xmax, ymax
bb <- c(xmin = -54.3533,
				ymin = 49.5194,
				xmax = -53.954220,
				ymax = 49.763834)

## Coastline
# Download osm coastlines in bbox
coast <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = 'coastline') %>%
	osmdata_sf()

# Grab polygons (small islands)
polys <- coast$osm_polygons

# Grab lines (large islands including Fogo)
lns <- coast$osm_lines

# Union -> polygonize -> cast lines = geo set
castpolys <- st_cast(st_polygonize(st_union(lns)))

# Combine geometries and cast as sf
islands <- st_as_sf(c(st_geometry(polys), castpolys))


## Water (internal)
water <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = 'water') %>%
	osmdata_sf()

# Grab polygons
mpols <- water$osm_multipolygons
pols <- water$osm_polygons[!is.na(water$osm_polygons$natural),]
onlywaterpols <- pols[pols$natural == 'water',]

# Union and combine
waterpols <- st_union(st_combine(mpols), st_combine(pols))

# Cut water out of islands
withPonds <- st_difference(islands, waterpols)
withoutPonds <- islands

## Roads
routes <- opq(bb) %>%
	add_osm_feature(key = 'highway') %>%
	osmdata_sf()

# Grab roads
roads <- routes$osm_lines


# NOTE: there is also wetland data





### Reproject ----
# Projections
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')

# Project to UTM
utmislands <- st_transform(withPonds, utm)
utmislandsNoPonds <- st_transform(withoutPonds, utm)
utmroads <- st_transform(roads, utm)

### Output ----
write_sf(utmislands, 'output/fogo-island-polygons.gpkg')
write_sf(utmislandsNoPonds, 'output/fogo-island-polygons-no-ponds.gpkg')
write_sf(utmroads, 'output/fogo-roads.gpkg')
