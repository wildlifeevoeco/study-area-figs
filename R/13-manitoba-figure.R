# === Manitoba - Figure ------------------------------
# Alec L. Robitaille


# Packages ----------------------------------------------------------------
libs <- c(
	'data.table',
	'ggplot2',
	'sf'
)
lapply(libs, require, character.only = TRUE)



# Data --------------------------------------------------------------------
bounds <- st_read('output/manitoba-bounds.gpkg')
lakes <- st_read('output/manitoba-lakes.gpkg')


# CRS
utm <- st_crs(4326)


# Theme -------------------------------------------------------------------
## Colors
source('R/00-palette.R')

## Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = landcol),
									panel.grid = element_line(color = gridcol, size = 0.3),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())


# Plot --------------------------------------------------------------------
# Base rmnp
mb <- bounds[bounds$name_en == 'Manitoba',]

bb <- st_bbox(st_buffer(st_centroid(mb), 1e9))
