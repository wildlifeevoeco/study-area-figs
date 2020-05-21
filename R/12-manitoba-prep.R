# === Manitoba - Prep -----------------------------------------------------
# Alec Robitaille



# Packages ----------------------------------------------------------------
libs <- c('sf', 'osmdata', 'rnaturalearth')
lapply(libs, require, character.only = TRUE)


# Download OSM data -------------------------------------------------------
## Bounds
bounds <- ne_download(
	scale = 'large',
	type = 'states',
	category = 'cultural',
	returnclass = 'sf'
)

keepAdmin <- c('United States of America', 'Canada', 'Greenland')

keepb <- bounds[bounds$admin %in% keepAdmin,]


## Lakes
lakes <- rnaturalearth::ne_download(
	scale = 'large',
	type = 'lakes',
	category = 'physical',
	returnclass = 'sf'
)

wi <- st_within(lakes, keepb)
subwi <- vapply(wi, function(x) length(x) >= 1, TRUE)

keepl <- lakes[subwi, ]


# Output ------------------------------------------------------------------
st_write(keepl, 'output/manitoba-lakes.gpkg')
st_write(keepb, 'output/manitoba-bounds.gpkg')
