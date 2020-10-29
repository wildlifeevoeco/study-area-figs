


# === Europe - Prep -----------------------------------------------------
# Alec Robitaille and Quinn M.R. Webber



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

keepAdmin <- c('Norway', 'Sweden', 'Denmark', 'Iceland', 'Finland')

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
st_write(keepl, 'output/Europe-lakes.gpkg', append = F)
st_write(keepb, 'output/Europe-bounds.gpkg', append = F)
