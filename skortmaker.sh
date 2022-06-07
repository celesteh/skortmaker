#!/usr/bin/bash

text="NEW MEME\nFORMAT"
size=100

color1=$(hexdump -n 3 -e '4/4 "%06X" 1 "\n"' /dev/urandom |xargs)
color2=$(hexdump -n 3 -e '4/4 "%06X" 1 "\n"' /dev/urandom|xargs)

num=$(date +%s)

# see https://www.redhat.com/sysadmin/arguments-options-bash-scripts
while getopts ":st:" option; do
   case $option in
      s) # size
         size=$OPTARG;;
      t) # Enter a string
         text=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

stroke=$(($size/50))
if [ $stroke -lt 1 ]; then
	stroke=1
fi

tmp="temp/blank$num.gif"

echo "$color1 $color2"

convert data/holed.gif -background "#ff000000" -font Open-Sans-Bold  \
	-strokewidth $stroke -pointsize $size -stroke white -fill black \
	 -gravity North -annotate 0 "$text" $tmp

convert -size 575x200 xc: +noise Random -separate \
          null: \( xc: +noise Random -separate -threshold 30% -negate \) \
              -compose CopyOpacity -layers composite \
          -set dispose background -set delay 20 -loop 0   temp/glitter_overlay.gif
          
convert temp/glitter_overlay.gif \
          -compose Screen -bordercolor GoldenRod -border 0x0  temp/glitter_gold.gif
          
convert temp/glitter_overlay.gif null: -size 575x200 \
      plasma:\#$color1-\#$color2 plasma:\#$color1-\#$color2  plasma:\#$color1-\#$color2 \
                   -compose Screen -layers composite    temp/glitter_plasma.gif


convert $tmp null: temp/glitter_plasma.gif -gravity South\
          -compose DstOver -layers composite \
          -loop 0 -layers Optimize out/skorts_glittered_$num\.gif
