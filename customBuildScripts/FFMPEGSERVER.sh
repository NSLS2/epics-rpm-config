
VERSION="ffmpeg-4.0.2"
SOURCE="https://ffmpeg.org/releases/${VERSION}.tar.xz"
YASM="http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz"

# fail if we can't do anything
set -e

# remove ffmpeg things in vendor dir
rm -rf vendor/ffmpeg*
rm -rf vendor/yasm*


# Now get the the zip files
for z in $SOURCE  $YASM; do
    wget -P "vendor" $z
done

# untar the source
echo "Untarring source..."
tar xf "vendor/$(basename $SOURCE)" -C "vendor"

# untar yasm
echo "Untarring yasm..."
tar xf "vendor/$(basename $YASM)" -C "vendor"

# move the untarred archives to the correct names
mv "vendor/${VERSION}" "vendor/ffmpeg"
mv "vendor/yasm-1.2.0" "vendor/yasm"

echo "You can now type make to build this module"

make -sj

rm vendor/ffmpeg-linux-x86_64/src
cp -r vendor/ffmpeg vendor/ffmpeg-linux-x86_64/src

cp -r lib/linux-x86_64 lib/linux-x86_64-debug
