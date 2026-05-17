# Generate town_tiles.png — 80x48 pixel art tileset (5 cols x 3 rows of 16x16).
# Layout matches the T_* constants in scenes/world/zone_setup.gd:
#   row 0: GRASS, PATH, ROAD, WATER, SIDEWALK
#   row 1: WALL,  ROOF
#   row 2: TRUNK, CANOPY, _, BENCH, LAMP
Add-Type -AssemblyName System.Drawing

function New-PixelBitmap([int]$w, [int]$h) {
    $bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    return $bmp
}

function Set-Px($bmp, $x, $y, $c) { $bmp.SetPixel($x, $y, $c) }

# Brand palette (matches branding/palette.gd)
$c_grass_a    = [System.Drawing.Color]::FromArgb(106, 153, 78)   # FOREST
$c_grass_b    = [System.Drawing.Color]::FromArgb(122, 169, 92)
$c_grass_dot  = [System.Drawing.Color]::FromArgb(94, 138, 70)
$c_path_a     = [System.Drawing.Color]::FromArgb(218, 200, 160)
$c_path_b     = [System.Drawing.Color]::FromArgb(200, 178, 140)
$c_path_dot   = [System.Drawing.Color]::FromArgb(180, 158, 120)
$c_road_a     = [System.Drawing.Color]::FromArgb(80, 80, 80)
$c_road_b     = [System.Drawing.Color]::FromArgb(96, 96, 96)
$c_road_line  = [System.Drawing.Color]::FromArgb(245, 194, 107)   # SUN_GOLD
$c_water_a    = [System.Drawing.Color]::FromArgb(70, 140, 180)
$c_water_b    = [System.Drawing.Color]::FromArgb(90, 165, 205)
$c_water_hi   = [System.Drawing.Color]::FromArgb(168, 218, 220)  # SKY
$c_walk_a     = [System.Drawing.Color]::FromArgb(190, 185, 175)
$c_walk_b     = [System.Drawing.Color]::FromArgb(160, 155, 145)
$c_wall_a     = [System.Drawing.Color]::FromArgb(120, 90, 70)
$c_wall_b     = [System.Drawing.Color]::FromArgb(95, 70, 55)
$c_wall_dark  = [System.Drawing.Color]::FromArgb(58, 42, 27)     # DEEP_BROWN
$c_roof_a     = [System.Drawing.Color]::FromArgb(200, 70, 60)    # CHERRY-ish
$c_roof_b     = [System.Drawing.Color]::FromArgb(165, 55, 50)
$c_roof_edge  = [System.Drawing.Color]::FromArgb(120, 40, 38)
$c_trunk_a    = [System.Drawing.Color]::FromArgb(95, 65, 40)
$c_trunk_b    = [System.Drawing.Color]::FromArgb(70, 45, 28)
$c_can_a      = [System.Drawing.Color]::FromArgb(60, 110, 55)
$c_can_b      = [System.Drawing.Color]::FromArgb(85, 140, 70)
$c_can_dark   = [System.Drawing.Color]::FromArgb(40, 75, 38)
$c_bench_a    = [System.Drawing.Color]::FromArgb(140, 90, 50)
$c_bench_b    = [System.Drawing.Color]::FromArgb(110, 70, 40)
$c_lamp_post  = [System.Drawing.Color]::FromArgb(58, 42, 27)
$c_lamp_glow  = [System.Drawing.Color]::FromArgb(245, 222, 130)
$c_transparent = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)

# Fill a 16x16 tile at (tx,ty) with a base color and a noise overlay
function Paint-Base($bmp, $tx, $ty, $baseColor, $variantColor) {
    $ox = $tx * 16; $oy = $ty * 16
    for ($y = 0; $y -lt 16; $y++) {
        for ($x = 0; $x -lt 16; $x++) {
            $h = ($x * 31 + $y * 17 + $tx * 7 + $ty * 13) % 7
            $c = if ($h -eq 0 -or $h -eq 4) { $variantColor } else { $baseColor }
            Set-Px $bmp ($ox + $x) ($oy + $y) $c
        }
    }
}

function Paint-Dot($bmp, $tx, $ty, $px, $py, $color) {
    Set-Px $bmp ($tx * 16 + $px) ($ty * 16 + $py) $color
}

$bmp = New-PixelBitmap 80 48

# Row 0
# (0,0) GRASS — base + tufted dots
Paint-Base $bmp 0 0 $c_grass_a $c_grass_b
foreach ($p in @(@(3,4),@(11,2),@(7,9),@(13,12),@(2,13),@(9,5))) {
    Paint-Dot $bmp 0 0 $p[0] $p[1] $c_grass_dot
}

# (1,0) PATH — dirt with stones
Paint-Base $bmp 1 0 $c_path_a $c_path_b
foreach ($p in @(@(3,5),@(11,3),@(7,10),@(2,12),@(13,9))) {
    Paint-Dot $bmp 1 0 $p[0] $p[1] $c_path_dot
}

# (2,0) ROAD — dark asphalt with center stripe
Paint-Base $bmp 2 0 $c_road_a $c_road_b
for ($y = 7; $y -le 8; $y++) {
    for ($x = 4; $x -le 11; $x++) {
        Paint-Dot $bmp 2 0 $x $y $c_road_line
    }
}

# (3,0) WATER — wavy bands
for ($y = 0; $y -lt 16; $y++) {
    for ($x = 0; $x -lt 16; $x++) {
        $band = ($y + [int]([Math]::Sin($x * 0.4) * 1.5)) % 4
        $c = if ($band -lt 2) { $c_water_a } else { $c_water_b }
        Set-Px $bmp (3 * 16 + $x) ($y) $c
    }
}
foreach ($p in @(@(2,3),@(9,7),@(13,11),@(5,12))) {
    Paint-Dot $bmp 3 0 $p[0] $p[1] $c_water_hi
}

# (4,0) SIDEWALK — light grey with cracks
Paint-Base $bmp 4 0 $c_walk_a $c_walk_b
for ($x = 0; $x -lt 16; $x++) {
    Paint-Dot $bmp 4 0 $x 7 $c_walk_b
    Paint-Dot $bmp 4 0 7 $x $c_walk_b
}

# Row 1
# (0,1) WALL — brick
Paint-Base $bmp 0 1 $c_wall_a $c_wall_b
# horizontal mortar lines
for ($x = 0; $x -lt 16; $x++) {
    Paint-Dot $bmp 0 1 $x 4 $c_wall_dark
    Paint-Dot $bmp 0 1 $x 9 $c_wall_dark
    Paint-Dot $bmp 0 1 $x 14 $c_wall_dark
}
# vertical mortar offset
for ($y = 0; $y -lt 4; $y++)  { Paint-Dot $bmp 0 1 7 $y $c_wall_dark }
for ($y = 5; $y -lt 9; $y++)  { Paint-Dot $bmp 0 1 3 $y $c_wall_dark; Paint-Dot $bmp 0 1 11 $y $c_wall_dark }
for ($y = 10; $y -lt 14; $y++){ Paint-Dot $bmp 0 1 7 $y $c_wall_dark }

# (1,1) ROOF — red tiles
Paint-Base $bmp 1 1 $c_roof_a $c_roof_b
for ($x = 0; $x -lt 16; $x++) {
    Paint-Dot $bmp 1 1 $x 0 $c_roof_edge
    Paint-Dot $bmp 1 1 $x 15 $c_roof_edge
    Paint-Dot $bmp 1 1 $x 5 $c_roof_edge
    Paint-Dot $bmp 1 1 $x 10 $c_roof_edge
}

# Row 2
# (0,2) TREE TRUNK
for ($y = 0; $y -lt 16; $y++) {
    for ($x = 0; $x -lt 16; $x++) {
        Set-Px $bmp ($x) (2 * 16 + $y) $c_transparent
    }
}
for ($y = 0; $y -lt 16; $y++) {
    for ($x = 5; $x -lt 11; $x++) {
        $c = if ($x -lt 7 -or $x -gt 9) { $c_trunk_b } else { $c_trunk_a }
        Set-Px $bmp $x (2 * 16 + $y) $c
    }
}

# (1,2) TREE CANOPY — round dense leaves
for ($y = 0; $y -lt 16; $y++) {
    for ($x = 0; $x -lt 16; $x++) {
        Set-Px $bmp (16 + $x) (2 * 16 + $y) $c_transparent
    }
}
for ($y = 0; $y -lt 16; $y++) {
    for ($x = 0; $x -lt 16; $x++) {
        $dx = $x - 7.5; $dy = $y - 7.5
        $d = [Math]::Sqrt($dx * $dx + $dy * $dy)
        if ($d -lt 7.5) {
            $h = ($x * 13 + $y * 7) % 5
            $c = if ($d -gt 6) { $c_can_dark } elseif ($h -lt 2) { $c_can_a } else { $c_can_b }
            Set-Px $bmp (16 + $x) (2 * 16 + $y) $c
        }
    }
}

# (3,2) BENCH
for ($y = 0; $y -lt 16; $y++) {
    for ($x = 0; $x -lt 16; $x++) {
        Set-Px $bmp (3 * 16 + $x) (2 * 16 + $y) $c_transparent
    }
}
# seat
for ($x = 2; $x -lt 14; $x++) {
    Set-Px $bmp (3 * 16 + $x) (2 * 16 + 7) $c_bench_a
    Set-Px $bmp (3 * 16 + $x) (2 * 16 + 8) $c_bench_b
}
# legs
for ($y = 9; $y -lt 14; $y++) {
    Set-Px $bmp (3 * 16 + 3) (2 * 16 + $y) $c_bench_b
    Set-Px $bmp (3 * 16 + 12) (2 * 16 + $y) $c_bench_b
}
# back
for ($y = 1; $y -lt 7; $y++) {
    Set-Px $bmp (3 * 16 + 3) (2 * 16 + $y) $c_bench_b
    Set-Px $bmp (3 * 16 + 12) (2 * 16 + $y) $c_bench_b
}
for ($x = 4; $x -lt 12; $x++) {
    Set-Px $bmp (3 * 16 + $x) (2 * 16 + 3) $c_bench_a
}

# (4,2) LAMP POST
for ($y = 0; $y -lt 16; $y++) {
    for ($x = 0; $x -lt 16; $x++) {
        Set-Px $bmp (4 * 16 + $x) (2 * 16 + $y) $c_transparent
    }
}
# post
for ($y = 4; $y -lt 15; $y++) {
    Set-Px $bmp (4 * 16 + 7) (2 * 16 + $y) $c_lamp_post
    Set-Px $bmp (4 * 16 + 8) (2 * 16 + $y) $c_lamp_post
}
# base
for ($x = 5; $x -lt 11; $x++) {
    Set-Px $bmp (4 * 16 + $x) (2 * 16 + 15) $c_lamp_post
}
# lamp head
for ($y = 1; $y -lt 5; $y++) {
    for ($x = 5; $x -lt 11; $x++) {
        $dx = $x - 7.5; $dy = $y - 2.5
        if ([Math]::Sqrt($dx * $dx + $dy * $dy) -lt 2.5) {
            Set-Px $bmp (4 * 16 + $x) (2 * 16 + $y) $c_lamp_glow
        }
    }
}

# Save
$bmp.Save("C:\Users\wysoc\Desktop\Pixel Life\assets\sprites\tilesets\town\town_tiles.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
"Saved town_tiles.png"
