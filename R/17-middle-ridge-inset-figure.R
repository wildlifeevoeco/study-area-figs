# === Middle Ridge - Inset Figure ------------------------------
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
crs <- st_crs('ESRI:102001')


# Theme -------------------------------------------------------------------
## Colors
source('R/00-palette.R')

## Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = gridcol, size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())


# Plot --------------------------------------------------------------------
bounds <- st_transform(bounds, crs)
lakes <- st_transform(lakes, crs)
nl <- st_transform(nl, crs)

on <- bounds[bounds$name == 'Manitoba',]
adjust <- 1.3e6
bb <- st_bbox(st_buffer(on, adjust))

gnl <- ggplot() +
	geom_sf(fill = islandcol, color = 'black', size = 0.1, data = bounds) +
	geom_sf(fill = watercol, color = streamcol, size = 0.1, data = lakes) +
	geom_sf(fill = '#cd0001', color = NA, alpha = 0.3, data = nl) +
	guides(color = FALSE, fill = FALSE) +
	labs(x = NULL, y = NULL) +
	coord_sf(xlim = c(bb['xmin'] - adjust, bb['xmax'] + adjust),
					 ylim = c(bb['ymin'] + adjust, bb['ymax'] + adjust)) +
	# geom_point(aes(x, y), size = 5, shape = 18,
	# 					 data = data.table(x = -295169, y = 1197566)) +
	theme(axis.text = element_blank(),
				axis.ticks = element_blank(),
				plot.margin = grid::unit(c(-1,-1,-1,-1), "mm"))

gnl

# Source MR figure ----------------------------------------------
source('R/16-middle-ridge-figure.R')




# Combine -----------------------------------------------------------------
# used the ggannotate package to make finding these numbers easier
g <- grmnp +
	annotation_custom(
		ggplotGrob(gmbAdjust),
		xmin = 340770,
		ymin = 5584909,
		xmax = 377059,
		ymax = 5612715)




# Output ------------------------------------------------------------------
ggsave(
	'graphics/14-riding-mountain-inset.png',
	g,
	width = 10,
	height = 10,
	dpi = 320
)
