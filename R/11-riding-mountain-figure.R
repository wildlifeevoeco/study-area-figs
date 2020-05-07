### Riding Mountain National Park Study Area Figure ====
# Alec L. Robitaille


### Packages ----
libs <- c(
	'data.table',
	'ggplot2',
	'sf',
	'raster'
)
lapply(libs, require, character.only = TRUE)


### Data ----
rmnp <- st_read('output/rmnp-bounds.gpkg')
roads <- st_read('output/rmnp-roads.gpkg')

water <- raster('output/rmnp-water.tif')
forest <- raster('output/rmnp-forest.tif')


