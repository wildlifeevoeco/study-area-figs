


# === Caribou diet - Figure ------------------------------
# Alec L. Robitaille and Quinn M.R. webber


# Packages ----------------------------------------------------------------
libs <- c(
	'data.table',
	'ggplot2',
	'sf'
)
lapply(libs, require, character.only = TRUE)



# Data --------------------------------------------------------------------
bounds <- st_read('output/large files/NA-bounds.gpkg')
lakes <- st_read('output/large files/NA-lakes.gpkg')

boundsEurope <- st_read('output/Europe-bounds.gpkg')
lakesEurope <- st_read('output/Europe-lakes.gpkg')


diet <- fread('../caribou-foraging/foraging/output/latitude.csv')
diet$longitude <- diet$longitude* -1

### Projection ----
projCols <- c('EASTING', 'NORTHING')

# CRS
crs <- st_crs('ESRI:102001')
crsEurope <- '+proj=moll'

# Theme -------------------------------------------------------------------
## Colors
source('R/00-palette.R')

## Theme
themeMap <- theme(legend.position = c(0.2, 0.8),
									panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = gridcol, size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())


# Plot --------------------------------------------------------------------
bounds <- st_transform(bounds, crs)
lakes <- st_transform(lakes, crs)

boundsEurope <- st_transform(boundsEurope, crsEurope)
lakesEurope <- st_transform(lakesEurope, crsEurope)


sites <- na.omit(data.table(latitude = diet$latitude,
										 longitude = diet$longitude,
										 herd = diet$herd))

sites <- sites[!duplicated(sites), ]


sites2 <- st_as_sf(sites, coords = c("longitude", "latitude"),
									 crs = 4326, agr = "constant")

# BB for North America
mb <- bounds[bounds$name_en == 'Manitoba',]
bb <- st_bbox(st_buffer(mb, 2.5e6))

# BB for Europe
swe <- boundsEurope[boundsEurope$name_en == 'Lapland',]
bb2 <- st_bbox(st_buffer(swe, 2.5e6))


caribou <- ggplot() +
	geom_sf(fill = islandcol, color = 'black', size = 0.1, data = bounds) +
	geom_sf(fill = watercol, color = streamcol, size = 0.1, data = lakes) +
  geom_sf(data = sites2, size = 2, alpha = 0.75, color = "darkred") +
	#scale_color_viridis_d() +
	guides(color = FALSE, fill = FALSE) +
	coord_sf(xlim = c(bb['xmin'], bb['xmax']),
					 ylim = c(bb['ymin'] + 2e6, bb['ymax'] + 400000) - 1e5) +
	themeMap


ggplot() +
	geom_sf(fill = islandcol, color = 'black', size = 0.1, data = boundsEurope) +
	geom_sf(fill = watercol, color = streamcol, size = 0.1, data = lakesEurope) +
	geom_sf(data = sites2, aes(color = herd), size = 1, alpha = 0.75, color = "black") +
	scale_color_viridis_d() +
	guides(color = FALSE, fill = FALSE) +
	coord_sf(xlim = c(bb2['xmin'], bb2['xmax']),
					 ylim = c(bb2['ymin'], bb2['ymax'])) +
	themeMap



# Output ------------------------------------------------------------------
ggsave(
	'graphics/21-caribou-diet.png',
	caribou,
	width = 10,
	height = 10,
	dpi = 320
)
