# === Manitoba - Prep -----------------------------------------------------
# Alec Robitaille



# Packages ----------------------------------------------------------------
libs <- c('sf', 'osmdata', 'rnaturalearth')
lapply(libs, require, character.only = TRUE)


# Download OSM data -------------------------------------------------------
bounds <- ne_download(
	scale = 'large',
	type = 'states',
	category = 'cultural',
	returnclass = 'sf'
)

keepAdmin <- c('United States of America', 'Canada')

keepb <- bounds[bounds$admin %in% keepAdmin,]



# Prep geometries ---------------------------------------------------------


# Output ------------------------------------------------------------------



