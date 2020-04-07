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

## Coastline
# Download osm coastlines in bbox
coast <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = 'coastline') %>%
	osmdata_sf()

# Grab polygons (small islands)
smallislands <- coast$osm_polygons

# Grab lines (large islands including Fogo)
coastline <- coast$osm_lines


## Water (internal)
water <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = 'water') %>%
	osmdata_sf()

# Grab polygons
mpols <- water$osm_multipolygons
pols <- water$osm_polygons

# Union and combine
waterpols <- st_union(st_combine(mpols), st_combine(pols))



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
utmsmallislands <- st_transform(smallislands, utm)
utmfogocoast <- st_transform(coastline, utm)

utmroads <- st_transform(roads, utm)

utmwater <- st_transform(waterpols, utm)

### Output ----
saveRDS(utmsmallislands, "output/fogo-small-islands.Rds")
saveRDS(utmfogocoast, "output/fogo-island-coastline.Rds")
saveRDS(utmroads, "output/fogo-roads.Rds")
saveRDS(utmwater, "output/fogo-water.Rds")
