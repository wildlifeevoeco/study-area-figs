# === Butter Pot Figure ---------------------------------------------------
# Emily Monk, Alec L. Robitaille


# Packages ----------------------------------------------------------------
libs <- c('sf', 'ggplot2', 'data.table')
lapply(libs, require, character.only = TRUE)



# Data --------------------------------------------------------------------
butter_pot <- st_read(file.path('output', 'butter-pot-protected-areas.gpkg'))
roads <- st_read(file.path('output', 'butter-pot-roads.gpkg'))
water <- st_read(file.path('output', 'butter-pot-water.gpkg'))
streams_lns <- st_read(file.path('output', 'butter-pot-streams-lns.gpkg'))
streams_pols <- st_read(file.path('output', 'butter-pot-streams-pols.gpkg'))
nl <- st_read(file.path('output', 'newfoundland-polygons.gpkg'))


# Select only main highway and primary
# TODO: check if you want to include other types of roads
#  with unique(roads$highway)
selroads <- c('trunk', 'primary')
highway <- roads[roads$highway %in% selroads,]



# Theme -------------------------------------------------------------------
# Colors
source('R/00-palette.R')

roadcols <- data.table(highway = selroads)
roadcols[, cols := gray.colors(.N, start = 0.1, end = 0.4)]
roadpal <- roadcols[, setNames(cols, highway)]


# Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = gridcol, size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())

# x/y limits (in meters)
bb <- st_bbox(butter_pot) - rep(c(1e3, -1e3), each = 2)



# Plot --------------------------------------------------------------------
# Crop NL
nlcrop <- st_crop(nl, bb + rep(c(-5e4, 5e4), each = 2))


(gbp <- ggplot() +
		geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = nlcrop) +
		geom_sf(fill = parkcol, size = 0.3, color = parkboundcol, data = butter_pot) +
		geom_sf(fill = watercol, size = 0.2, color = coastcol, data = water) +
		geom_sf(fill = streampolcol, color = NA, data = streams_pols) +
		geom_sf(color = streamcol, size = 0.4, data = streams_lns) +
		geom_sf(aes(color = highway), data = highway) +
		geom_sf_label(aes(label = 'Butter Pot Provincial'), size = 5, fontface = 'bold',
									data = butter_pot) +
		scale_color_manual(values = roadpal) +
		coord_sf(xlim = c(bb['xmin'], bb['xmax']),
						 ylim = c(bb['ymin'], bb['ymax'])) +
		guides(color = 'none') +
		themeMap)


# Output ------------------------------------------------------------------
ggsave(
	'graphics/23-butter-pot.png',
	gbp,
	width = 10,
	height = 10,
	dpi = 320
)
