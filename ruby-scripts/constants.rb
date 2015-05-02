# Licensed under The MIT License (MIT)
#
# Copyright (c) 2015 Cara McCormack
#
# For more information view the project README
# or visit http://opensource.org/licenses/MIT

$tv_shows = 'caramcc_tv_shows'
$actors = 'caramcc_actors'
$show_actors = 'caramcc_show_actors'
$creators = 'caramcc_creators'
$show_creators = 'caramcc_show_creators'

$show_genres = 'caramcc_show_genres'
$show_airdays = 'caramcc_show_airdays'
$show_languages = 'caramcc_show_languages'
$show_alt_titles = 'caramcc_show_alt_titles'

$networks = 'caramcc_networks'

$updates = 'caramcc_updates'



# MISC
# first update timestamp
$first_update = 1426550400 # 17 Mar 2015

# acceptable TV Rage Fields
$tvr_fields = %w(showname origin_country startdate ended classification runtime airtime airday timezone)
$tvr_arrays = %w(genres akas)

# acceptable OMDB fields


# DATABASES

# Local
$db_name = 'caramcc_dbd_project'
$host = 'localhost'
$username = 'root'
$password = ''

# Bangerz
# $db_name = 'gsmp'
# $host = 'localhost'
# $username = 'gsmp'
# $password = ''