# === Middle Ridge - Inset Figure ------------------------------
# Alec L. Robitaille


# Packages ----------------------------------------------------------------
libs <- c(
	'data.table',
	'ggplot2',
	'sf',
	'rnaturalearth',
	'rnaturalearthhires',
	'scico',
	'stringr'
)
lapply(libs, require, character.only = TRUE)



# Data --------------------------------------------------------------------
bounds <- st_read('output/manitoba-bounds.gpkg')
lakes <- st_read('output/manitoba-lakes.gpkg')
areas <- st_read('output/mr-protected-areas.gpkg')
nl <- st_read('output/newfoundland-polygons.gpkg')

herds <- st_read('input/NL-caribou-calving-mcps-50p.gpkg')
ca_bounds <- ne_states('Canada', returnclass = 'sf')

# CRS
crs <- st_crs('ESRI:102001')
crs_herds <- st_crs(herds)


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
areas <- st_transform(areas, crs)


mb <- bounds[bounds$name == 'Manitoba',]
adjust <- 1.3e6
bb <- st_bbox(st_buffer(mb, adjust))

gnl <- ggplot() +
	geom_sf(fill = islandcol, color = 'grey20', linewidth = 0.1, data = bounds) +
	geom_sf(fill = watercol, color = streamcol, linewidth = 0.1, data = lakes) +
	# geom_sf(fill = '#', color = NA, data = nl) +
	guides(color = FALSE, fill = FALSE) +
	labs(x = NULL, y = NULL) +
	coord_sf(xlim = c(bb['xmin'] - adjust, bb['xmax'] + adjust),
					 ylim = c(bb['ymin'] + adjust, bb['ymax'] + adjust)) +
	geom_point(aes(x, y), size = 8, shape = 1, stroke = 1.5,
						 data = data.table(x = 2856789, y = 1795543)) +
	themeMap +
	theme(axis.text = element_blank(),
				axis.ticks = element_blank(),
				plot.margin = grid::unit(c(-1,-1,-1,-1), "mm"))



# NL herds ----------------------------------------------------------------
bounds <- st_transform(bounds, crs_herds)
ca_bounds <- st_transform(bounds, crs_herds)
nl <- st_transform(nl, crs_herds)
lakes <- st_transform(lakes, crs_herds)
areas <- st_transform(areas, crs_herds)

bb <- st_bbox(nl)

g_herds <- ggplot() +
	geom_sf(fill = islandcol, color = 'black', linewidth = 0.3, data = ca_bounds) +
	geom_sf(fill = watercol, color = streamcol, linewidth = 0.1, data = lakes) +
	geom_sf(aes(fill = str_to_sentence(herd)), alpha = 0.8, data = herds) +
	guides(color = FALSE) +
	scale_fill_scico_d(palette = 'tokyo') +
	labs(x = NULL, y = NULL, fill = 'Herd') +
	coord_sf(xlim = c(bb['xmin'], bb['xmax']),
					 ylim = c(bb['ymin'], bb['ymax'])) +
	themeMap


# Combine -----------------------------------------------------------------
# used the ggannotate package to make finding these numbers easier
g <- g_herds +
	annotation_custom(
		ggplotGrob(gnl),
		xmin = 660957.51487944, xmax = 828089.05257478,
		ymin = 5547949.0686487, ymax = 5715080.6063441)


# Output ------------------------------------------------------------------
ggsave(
	'graphics/24-newfoundland-caribou-herds-inset.png',
	g,
	width = 10,
	height = 10,
	dpi = 320
)

