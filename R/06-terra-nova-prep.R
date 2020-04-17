### Terra Nova prep ====
# Alec L. Robitaille, Isabella Richmond


### Packages ----
libs <- c('curl', 'zip', 'sf', 'osmdata')
lapply(libs, require, character.only = TRUE)


### Download Terra Nova data ----
## Polygon from Open Canada
# https://open.canada.ca/data/en/dataset/e1f0c975-f40c-4313-9be2-beb951e35f4e
curl_download('http://ftp.maps.canada.ca/pub/pc_pc/National-parks_Parc-national/national_parks_boundaries/national_parks_boundaries.shp.zip', 'input/national-parks.zip')
dir.create('input')
unzip('input/national-parks.zip', exdir = 'input/national-parks')

parks <- st_read('input/national-parks')

tn <- parks[parks$parkname_e == 'Terra Nova National Park of Canada', ]


## Roads
# Need latlon
bb <- st_bbox(st_transform(st_buffer(tn, 1e4), 4326))
routes <- opq(bb) %>%
	add_osm_feature(key = 'highway') %>%
	osmdata_sf()

# Grab roads
roads <- routes$osm_lines

# Water (internal)
water <- opq(bb) %>%
	add_osm_feature(key = 'natural', value = 'water') %>%
	osmdata_sf()

# Grab polygons
mpols <- water$osm_multipolygons

# Union and combine
waterpols <- st_union(st_combine(mpols))


# Streams
waterways <- opq(bb) %>%
	add_osm_feature(key = 'waterway') %>%
	osmdata_sf()

streamsPol <- st_cast(st_polygonize(st_union(waterways$osm_lines)))
streamsLns <- waterways$osm_lines

### Reproject ----
# Projection
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')

# Project to UTM
utmTN <- st_transform(tn, utm)
utmRoads <- st_transform(roads, utm)
utmWater <- st_transform(waterpols, utm)
utmStreamsLns <- st_transform(streamsLns, utm)
utmStreamsPol <- st_transform(streamsPol, utm)

### Output ----
st_write(utmTN, 'output/terra-nova-polygons.gpkg')
st_write(utmRoads, 'output/terra-nova-roads.gpkg')
st_write(utmWater, 'output/terra-nova-water.gpkg')
st_write(utmStreamsLns, 'output/terra-nova-streams-lns.gpkg')
st_write(utmStreamsPol, 'output/terra-nova-streams-pols.gpkg')
