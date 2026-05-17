# Generate player_sprites.png — 48x64 (3 frames x 4 directions, 16x16 each).
# Row order matches player_controller.gd:_setup_animations(): 0=down, 1=up, 2=left, 3=right.
Add-Type -AssemblyName System.Drawing

$skin  = [System.Drawing.Color]::FromArgb(245, 220, 180)
$skin2 = [System.Drawing.Color]::FromArgb(225, 195, 160)
$hair  = [System.Drawing.Color]::FromArgb(70, 45, 28)
$shirt = [System.Drawing.Color]::FromArgb(46, 110, 120)   # BRAND_TEAL
$shirt2= [System.Drawing.Color]::FromArgb(35, 88, 95)
$pants = [System.Drawing.Color]::FromArgb(60, 50, 75)
$shoe  = [System.Drawing.Color]::FromArgb(40, 30, 20)
$out   = [System.Drawing.Color]::FromArgb(20, 14, 10)
$tx    = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)

$bmp = New-Object System.Drawing.Bitmap 48, 64, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

function Set-Px($x, $y, $c) { if ($x -ge 0 -and $x -lt 48 -and $y -ge 0 -and $y -lt 64) { $bmp.SetPixel($x, $y, $c) } }

# Initialize fully transparent
for ($y = 0; $y -lt 64; $y++) { for ($x = 0; $x -lt 48; $x++) { Set-Px $x $y $tx } }

# Draw an outlined rectangle (filled).
function Rect($ox, $oy, $x, $y, $w, $h, $fill) {
    for ($yy = 0; $yy -lt $h; $yy++) {
        for ($xx = 0; $xx -lt $w; $xx++) {
            Set-Px ($ox + $x + $xx) ($oy + $y + $yy) $fill
        }
    }
}
function Pix($ox, $oy, $x, $y, $c) { Set-Px ($ox + $x) ($oy + $y) $c }

# Draws one 16x16 frame at (ox, oy). $dir: 0=down,1=up,2=left,3=right. $step: 0=idle,1=left,2=right
function Draw-Frame($ox, $oy, $dir, $step) {
    # Outline silhouette (head + body)
    # head: rows 2..6, x 5..10
    Rect $ox $oy 5 2 6 5 $skin
    Pix $ox $oy 4 3 $out; Pix $ox $oy 11 3 $out
    Pix $ox $oy 4 4 $out; Pix $ox $oy 11 4 $out
    Pix $ox $oy 4 5 $out; Pix $ox $oy 11 5 $out
    Pix $ox $oy 5 1 $out; Pix $ox $oy 6 1 $out; Pix $ox $oy 7 1 $out; Pix $ox $oy 8 1 $out; Pix $ox $oy 9 1 $out; Pix $ox $oy 10 1 $out
    Pix $ox $oy 5 6 $out; Pix $ox $oy 10 6 $out

    # hair on top of head depending on direction
    if ($dir -eq 0) {
        # facing down — hair across top + sides
        for ($x = 5; $x -le 10; $x++) { Pix $ox $oy $x 2 $hair }
        Pix $ox $oy 5 3 $hair; Pix $ox $oy 10 3 $hair
        # eyes
        Pix $ox $oy 6 4 $out
        Pix $ox $oy 9 4 $out
        # mouth
        Pix $ox $oy 7 5 $out; Pix $ox $oy 8 5 $out
    } elseif ($dir -eq 1) {
        # facing up — full back of head is hair
        for ($y = 2; $y -le 6; $y++) { for ($x = 5; $x -le 10; $x++) { Pix $ox $oy $x $y $hair } }
    } elseif ($dir -eq 2) {
        # facing left
        for ($x = 5; $x -le 10; $x++) { Pix $ox $oy $x 2 $hair }
        # left side hair
        Pix $ox $oy 5 3 $hair; Pix $ox $oy 5 4 $hair; Pix $ox $oy 5 5 $hair
        Pix $ox $oy 6 3 $hair
        # eye
        Pix $ox $oy 7 4 $out
        Pix $ox $oy 7 5 $out
    } else {
        # facing right
        for ($x = 5; $x -le 10; $x++) { Pix $ox $oy $x 2 $hair }
        Pix $ox $oy 10 3 $hair; Pix $ox $oy 10 4 $hair; Pix $ox $oy 10 5 $hair
        Pix $ox $oy 9 3 $hair
        Pix $ox $oy 8 4 $out
        Pix $ox $oy 8 5 $out
    }

    # Body / shirt: rows 7..11, x 4..11
    Rect $ox $oy 4 7 8 5 $shirt
    # shirt shading
    for ($y = 7; $y -le 11; $y++) {
        Pix $ox $oy 4 $y $shirt2
        Pix $ox $oy 11 $y $shirt2
    }
    # arms (different per step for swing)
    $armOffset = 0
    if ($step -eq 1) { $armOffset = -1 } elseif ($step -eq 2) { $armOffset = 1 }
    # left arm at column 3, right arm at column 12
    Pix $ox $oy 3 (8 + $armOffset) $skin
    Pix $ox $oy 3 (9 + $armOffset) $skin
    Pix $ox $oy 3 (10 + $armOffset) $skin2
    Pix $ox $oy 12 (8 - $armOffset) $skin
    Pix $ox $oy 12 (9 - $armOffset) $skin
    Pix $ox $oy 12 (10 - $armOffset) $skin2
    # body outline
    Pix $ox $oy 3 7 $out; Pix $ox $oy 12 7 $out
    Pix $ox $oy 4 11 $out; Pix $ox $oy 11 11 $out

    # Legs / pants: rows 12..14, x 5..10
    Rect $ox $oy 5 12 6 3 $pants
    # leg split
    Pix $ox $oy 7 12 $out; Pix $ox $oy 7 13 $out; Pix $ox $oy 8 12 $out; Pix $ox $oy 8 13 $out

    # Shoes: row 14..15
    if ($step -eq 0) {
        Rect $ox $oy 5 14 2 2 $shoe
        Rect $ox $oy 9 14 2 2 $shoe
    } elseif ($step -eq 1) {
        # left foot forward
        Rect $ox $oy 4 14 3 2 $shoe
        Rect $ox $oy 9 14 2 1 $shoe
    } else {
        Rect $ox $oy 5 14 2 1 $shoe
        Rect $ox $oy 9 14 3 2 $shoe
    }
}

# 4 rows x 3 cols
for ($dir = 0; $dir -lt 4; $dir++) {
    for ($step = 0; $step -lt 3; $step++) {
        Draw-Frame ($step * 16) ($dir * 16) $dir $step
    }
}

$bmp.Save("C:\Users\wysoc\Desktop\Pixel Life\assets\sprites\characters\player_sprites.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
"Saved player_sprites.png"
