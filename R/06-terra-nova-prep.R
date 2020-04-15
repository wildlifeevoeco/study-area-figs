### Terra Nova prep ====
# Alec L. Robitaille, Isabella Richmond


### Packages ----
libs <- c('curl', 'zip')
lapply(libs, require, character.only = TRUE)


### Download Terra Nova polygon ----
# From Open Canada
# https://open.canada.ca/data/en/dataset/e1f0c975-f40c-4313-9be2-beb951e35f4e
curl_download('http://ftp.maps.canada.ca/pub/pc_pc/National-parks_Parc-national/national_parks_boundaries/national_parks_boundaries.shp.zip', 'input/national_parks.zip')

zip::unzip('input/national_parks.zip', exdir = 'input/national_parks')

parks <- st_read('input/national-parks.zip',)
zip::unzip()


tn <-



tnbbox <- searchbbox("Terra Nova National Park")

canvec.qplot(bbox=tnbbox)

zz <- opq(getbb('Newfoundland')) %>%
	add_osm_feature(key = 'name', value = 'Parc national du Canada Terra-Nova national park of Canada', value_exact = FALSE) %>%
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
saveRDS(utmNL, 'output/newfoundland-polygons.Rds')
