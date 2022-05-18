for i in charts/*.tgz; do

    [ -f "$i" ] || break

    str=$(echo $i | cut -d'/' -f 2)
    imageName=$(echo $str | cut -d'-' -f 1)
    echo $imageName
done