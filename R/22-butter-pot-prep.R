# === Butter Pot Prep -----------------------------------------------------
# Emily Monk, Alec L. Robitaille


# Packages ----------------------------------------------------------------
libs <- c('sf', 'osmdata')
lapply(libs, require, character.only = TRUE)



# Protected areas ---------------------------------------------------------
# Butterpot shapefile:
# https://www.gov.nl.ca/tcar/home/parks/gis-data/
protected <- st_read(file.path(
	'input',
	'NL_Provincial_Protected_Areas_Sept9_2016',
	'NL_Provincial_Protected_Areas_Sept9_2016.shp'
))
butter_pot <- protected[grepl('Butter', protected$NAME_E),]



# Download OSM data -------------------------------------------------------
map_bb <- st_bbox(butter_pot) + c(-0.2, -0.2, 0.2, 0.2)

# Roads
routes <- opq(map_bb) %>%
	add_osm_feature(key = 'highway') %>%
	osmdata_sf()
roads <- routes$osm_lines

# Water (internal)
water <- opq(map_bb) %>%
	add_osm_feature(key = 'natural', value = 'water') %>%
	osmdata_sf()

# Grab polygons
mpols <- water$osm_multipolygons

# Union and combine
# Getting a invalid geometry from OSM with spherical geometry
# Turning off for this operation
# https://github.com/r-spatial/sf/issues/1762
# https://r-spatial.org/book/04-Spherical.html#validity-on-the-sphere
sf_use_s2(FALSE)
waterpols <- st_union(st_combine(mpols))
sf_use_s2(TRUE)

# Streams
waterways <- opq(map_bb) %>%
	add_osm_feature(key = 'waterway') %>%
	osmdata_sf()

streamsPol <- st_cast(st_polygonize(st_union(waterways$osm_lines)))
streamsLns <- waterways$osm_lines



# Reprojection ------------------------------------------------------------
utm <- st_crs(32621)

# Project to UTM
utm_protected <- st_transform(protected, utm)
utm_butter_pot <- st_transform(butter_pot, utm)
utm_roads <- st_transform(roads, utm)
utm_water <- st_transform(waterpols, utm)
utm_streams_lns <- st_transform(streamsLns, utm)
utm_streams_pols <- st_transform(streamsPol, utm)



# Output ------------------------------------------------------------------
st_write(utm_protected, file.path('output', 'newfoundland-protected-areas.gpkg'),
				 append = FALSE)
st_write(utm_butter_pot, file.path('output', 'butter-pot-protected-areas.gpkg'),
				 append = FALSE)
st_write(utm_roads, file.path('output', 'butter-pot-roads.gpkg'),
				 append = FALSE)
st_write(utm_water, file.path('output', 'butter-pot-water.gpkg'),
				 append = FALSE)
st_write(utm_streams_lns, file.path('output', 'butter-pot-streams-lns.gpkg'),
				 append = FALSE)
st_write(utm_streams_pols, file.path('output', 'butter-pot-streams-pols.gpkg'),
				 append = FALSE)

