# === Butter Pot Prep -----------------------------------------------------
# Emily Monk, Alec L. Robitaille

#shape file for butterpot was downloaded from here:
#https://www.gov.nl.ca/tcar/home/parks/gis-data/

shp <- readOGR("ProvincialProtectedAreasNL/NL_Provincial_Protected_Areas_Sept9_2016.shp", stringsAsFactors = F)
#Butterpot provincial park is number 53 in the data frame
bp_shp <- shp[53,]

map <- ggplot() + geom_polygon(data = bp_shp, aes(x = long, y = lat, group = group), colour = "black")

map + theme_void()

#just saving this in case I need it later, map extent for whole island
mapExtent <- rbind(c(-59.5, 52), c(46.3, -51.3))



#now attempting putting butterpot into NL
#Start with preparing the NL map, code from Alec with modification 
# Packages ----------------------------------------------------------------
libs <- c('sf', 'osmdata')
lapply(libs, require, character.only = TRUE)

# Download OSM data -------------------------------------------------------
# Download osm coastlines in bbox
# NOTE: This steps takes a few moments

#Work around to get bbox with current error
nominatim_polygon <- nominatimlite::geo_lite_sf(address = "Newfoundland", points_only = FALSE)
nl_bbox <- sf::st_bbox(nominatim_polygon)
#use the work around bbox in the osm query
zz <- opq(nl_bbox) %>%
  add_osm_feature(key = 'place', value = 'island') %>%
  osmdata_sf()

# Grab lines
lns <- zz$osm_lines

# Union -> polygonize -> cast lines = geometry set
castpolys <- st_cast(st_polygonize(st_union(lns)))

# Combine geometries and cast as sf
nl <- st_as_sf(castpolys)

# Reproject islands -------------------------------------------------------
# Projections
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')

# Project to UTM
utmNL <- st_transform(nl, utm)

# Output ------------------------------------------------------------------
st_write(utmNL, 'newfoundland-polygons.gpkg')
# Protected areas ---------------------------------------------------------
# Butterpot shapefile:
# https://www.gov.nl.ca/tcar/home/parks/gis-data/
protected <- st_read(file.path(
	'input',
	'NL_Provincial_Protected_Areas_Sept9_2016',
	'NL_Provincial_Protected_Areas_Sept9_2016.shp'
))
butter_pot <- protected[grepl('Butter', protected$NAME_E),]



####################################################
#Now prepare the butterpot area, as was done in the code for terra nova by Alec
map_bb <- bp_shp@bbox + c(-0.5, -0.5, 0.5, 0.5)
map_bb <- st_bbox(butter_pot) + c(-0.2, -0.2, 0.2, 0.2)

routes <- opq(map_bb) %>%
  add_osm_feature(key = 'highway') %>%
  osmdata_sf()

# Grab roads
roads <- routes$osm_lines

# Water (internal)
water <- opq(map_bb) %>%
  add_osm_feature(key = 'natural', value = 'water') %>%
  osmdata_sf()

# Grab polygons
mpols <- water$osm_multipolygons

#!!!!!! Error here.
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
#shape file doesn't do this transformation, not sure what I need here
#utmbp <- st_transform(bp_shp, utm)
utmRoads <- st_transform(roads, utm)
#water isn't working, sticking point above
utmWater <- st_transform(waterpols, utm)
utmStreamsLns <- st_transform(streamsLns, utm)
utmStreamsPol <- st_transform(streamsPol, utm)




# Output ------------------------------------------------------------------
#st_write(utmTN, 'output/terra-nova-polygons.gpkg')
st_write(utmRoads, 'bp-roads.gpkg')
#the water one isn't working
st_write(utmWater, 'bp-water.gpkg')
st_write(utmStreamsLns, 'bp-streams-lns.gpkg')
st_write(utmStreamsPol, 'bp-streams-pols.gpkg')

