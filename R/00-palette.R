### Palette - Study area figure ====
# Alec Robitaille

# Water
watercol <- '#c3e2ec'
streamcol <- '#7e9da7'
streampolcol <- '#9cb4bc'
coastcol <- '#b59f78'

# Land
islandcol <- '#d0c2a9'
landcol <- '#d9ceba'

# Anthro
roadcol <- '#666666'

parkcol <- '#b4bc9c'
parkboundcol <- '#90967c'

# Forest
forestcol <- '#A4BC9C'

# Map etc
gridcol <- '#323232'


# Road hiearchy
levels <- c('motorway', 'trunk', 'primary', 'secondary', 'tertiary',
						'unclassified', 'residential', 'motorway_link', 'trunk_link',
						'primary_link', 'secondary_link', 'tertiary_link',
						'living_street', 'service', 'pedestrian', 'track',
						'bus_guideway', 'escape', 'raceway', 'road', 'footway',
						'bridleway', 'steps', 'corridor', 'path', 'sidewalk',
						'cycleway')
roadlevels <- factor(levels, levels = levels)
