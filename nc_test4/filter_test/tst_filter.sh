#!/bin/sh

if test "x$srcdir" = x ; then srcdir=`pwd`; fi
. ../../test_common.sh

set -e
set -x
export HDF5_PLUGIN_PATH=`pwd`

API=1
NG=1
NCP=1
UNK=1

# Function to remove selected -s attributes from file;
# These attributes might be platform dependent
sclean() {
cat $1 \
  | sed -e '/var:_Endianness/d' \
  | sed -e '/_NCProperties/d' \
  | sed -e '/_SuperblockVersion/d' \
  | sed -e '/_IsNetcdf4/d' \
  | cat > $2
}

if test "x$API" = x1 ; then
echo "*** Testing dynamic filters using API"
rm -f ./bzip2.nc ./bzip2.dump ./tmp
${execdir}/test_filter
$NCDUMP -s ./bzip2.nc > ./tmp
# Remove irrelevant -s output
sclean ./tmp ./bzip2.dump
diff -b -w ${srcdir}/bzip2.cdl ./bzip2.dump
echo "*** Pass: API dynamic filter"
fi

if test "x$NCP" = x1 ; then
echo "*** Testing dynamic filters using nccopy"
rm -f ./unfiltered.nc ./filtered.nc ./filtered.dump ./tmp
$NCGEN -4 -lb -o unfiltered.nc ${srcdir}/unfiltered.cdl
$NCCOPY -F "/g/var,307,9" unfiltered.nc filtered.nc
$NCDUMP -s ./filtered.nc > ./tmp
# Remove irrelevant -s output
sclean ./tmp ./filtered.dump
diff -b -w ${srcdir}/filtered.cdl ./filtered.dump
echo "*** Pass: nccopy dynamic filter"
fi

if test "x$NG" = x1 ; then
echo "*** Testing dynamic filters using ncgen"
rm -f ./bzip2.nc ./bzip2.dump ./tmp
$NCGEN -lb -4 -o bzip2.nc ${srcdir}/bzip2.cdl
$NCDUMP -s ./bzip2.nc > ./tmp
# Remove irrelevant -s output
sclean ./tmp ./bzip2.dump
diff -b -w ${srcdir}/bzip2.cdl ./bzip2.dump
echo "*** Pass: ncgen dynamic filter"
fi

if test "x$UNK" = x1 ; then
echo "*** Testing access to filter info when filter dll is not available"
rm -f bzip2.nc ./tmp
# build bzip2.nc
$NCGEN -lb -4 -o bzip2.nc ${srcdir}/bzip2.cdl
for f in cygbzip2.dll libbzip2.so ; do
  if test -f ${execdir}/$f ; then LIBNAME=${execdir}/$f; fi;
done
# dump and clean bzip2.nc header only when filter is avail
$NCDUMP -hs ./bzip2.nc > ./tmp
# Remove irrelevant -s output
sclean ./tmp bzip2.dump
# Now hide the filter code
mv ${LIBNAME} ${LIBNAME}.save
# dump and clean bzip2.nc header only when filter is not avail
rm -f ./tmp
$NCDUMP -hs ./bzip2.nc > ./tmp
# Remove irrelevant -s output
sclean ./tmp bzip2x.dump
# Restore the filter code
mv ${LIBNAME}.save ${LIBNAME}
diff -b -w ./bzip2.dump ./bzip2x.dump
echo "*** Pass: ncgen dynamic filter"
fi

#cleanup
rm -f ${LIBNAME}
rm -f ./bzip*.nc ./unfiltered.nc ./filtered.nc ./tmp ./tmp2 *.dump bzip*hdr.*
exit 0
