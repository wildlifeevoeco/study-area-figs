### Terra Nova prep ====
# Alec L. Robitaille, Isabella Richmond


### Packages ----
libs <- c('sf',
					'osmdata')
lapply(libs, require, character.only = TRUE)


### Input data ----
# Terra Nova polygon
# from: https://open.canada.ca/data/en/dataset/e1f0c975-f40c-4313-9be2-beb951e35f4e
tn <- st_read('input/terra-nova-national-park.gpkg')



### Download OSM data ----
# Download park boundaries


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
