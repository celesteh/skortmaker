#!/usr/bin/bash

TEXT=""
SIZE=100

color1=$(hexdump -n 3 -e '4/4 "%06X" 1 "\n"' /dev/urandom |xargs)
color2=$(hexdump -n 3 -e '4/4 "%06X" 1 "\n"' /dev/urandom|xargs)

num=$(date +%s)

function show_usage() {
	echo "Usage $0 [options paramaters]"
	echo ""
	echo "Options:"
	echo "-s|-size font size"
	echo "-t|--text text"
	echo "-h|--help"
return 0
}

# see https://www.golinuxcloud.com/beginners-guide-to-use-script-arguments-in-bash-with-examples/
while [ ! -z "$1" ];do
   case "$1" in
        -h|--help)
          show_usage
          exit
          ;;
        -t|--text)
          shift
          TEXT="$1"
          ;;
        -s|--size)
          shift
          SIZE="$1"
          ;;
        *)
       echo "Incorrect input provided"
       show_usage
       exit
   esac
shift
done

## see https://www.redhat.com/sysadmin/arguments-options-bash-scripts
#while getopts ":st:" option; do
#   case $option in
#      s) # size
#      	 echo "size $OPTARG"
#         size=$(($OPTARG));;
#      t) # Enter a string
#         text=$OPTARG;;
#     \?) # Invalid option
#         echo "Error: Invalid option"
#         exit;;
#   esac
#done

#echo "size is $SIZE $stroke"

if [ $SIZE -lt 1 ]; then
	SIZE=1
fi

stroke=$(($SIZE/50))
if [ $stroke -lt 1 ]; then
	stroke=1
fi


tmp="temp/blank$num.gif"

echo "$color1 $color2"

convert data/holed.gif -background "#ff000000" -font Open-Sans-Bold  \
	-strokewidth $stroke -pointsize $SIZE -stroke white -fill black \
	 -gravity North -annotate 0 "$TEXT" $tmp

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
