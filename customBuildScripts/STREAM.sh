make -sj


mkdir dbd
mkdir db
mkdir lib
mkdir lib/linux-x86_64
mkdir lib/linux-x86_64-debug
mkdir bin
mkdir bin/linux-x86_64
mkdir bin/linux-x86_64-debug

# Copy dbd and libs because for some reason just make doesn't install them properly
cp src/O.*/*.dbd dbd/.
cp src/O.linux-x86_64/libstream.* lib/linux-x86_64/.
cp src/O.linux-x86_64-debug/libstream.* lib/linux-x86_64-debug/.


# Build again, to make sure that it built OK the first time
make -sj

