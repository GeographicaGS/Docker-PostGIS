#!/bin/bash

echo From 23030 to 25830
echo Results should be:
echo 235094 4141906
echo 265353.396 3987805.481
echo ">>>"
cs2cs +init=epsg:23030 +to +init=epsg:25830 -w5 <<EOF
235205.243 4142110.093
265467 3988010
EOF

echo
echo From 25830 to 23030
echo Results should be:
echo 235205.243 4142110.093
echo 265467 3988010
echo ">>>"
cs2cs +init=epsg:25830 +to +init=epsg:23030 -w5 <<EOF
235094 4141906
265353.396 3987805.481
EOF

echo
echo From 4230 to 4326
echo Results should be:
echo 5d59\'31.59731\"W 37d23\'9.92266\"N
echo 5d36\'12.32786\"W 36d0\'23.43887\"N
echo ">>>"
cs2cs +init=epsg:4230 +to +init=epsg:4326 -w5 <<EOF
5d59'26.77534"W 37d23'14.45571"N
5d36'7.53"W 36d0'28.1"N
EOF

echo
echo From 4326 to 4230
echo Results should be:
echo 5d59\'26.77534\"W 37d23\'14.45571\"N
echo 5d36\'7.53\"W 36d0\'28.1N\"
echo ">>>"
cs2cs +init=epsg:4326 +to +init=epsg:4230 -w5 <<EOF
5d59'31.59731"W 37d23'9.92266"N
5d36'12.32786"W 36d0'23.43887"N
EOF
