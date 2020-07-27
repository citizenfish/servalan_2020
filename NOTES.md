Maps Plugin development

https://doc-snapshots.qt.io/qt-mobility/location-overview.html#implementing-plugins

http://computerexpress5.blogspot.com/2017/11/briefly-on-how-to-make-your-qt.html

Some examples

https://github.com/vladest?tab=repositories

https://www.maptiler.com/news/2019/04/using-maptiler-maps-inside-qt/

Custom tile sets

https://stackoverflow.com/questions/53112393/qml-openstreetmap-custom-tiles

Setting Mapbox json path

https://github.com/maptiler/maptiler-qml-demo/blob/master/Readme.md


gdal build


wget https://download.osgeo.org/gdal/2.4.4/gdal-2.4.4.tar.gz
tar -xvf gdal-2.4.4.tar.gz
make distclean
./configure --with-geos=/usr/local/bin/geos-config --with-gif=internal --with-jpeg=internal  --enable-shared=no
make
sudo make install


NOTE WELL: https://stackoverflow.com/questions/38131011/qt-application-throws-dyld-symbol-not-found-cg-jpeg-resync-to-restart

GO TO Projects -> Run -> "Run Environment" (show Details), select DYLD_LIBRARY_PATH and click Unset. After this, your project should compile as expected.

CONFIG_VERSION=3.0.4
CONFIG_INST_PREFIX=/usr/local
CONFIG_INST_LIBS=-L/usr/local/lib -lgdal
CONFIG_INST_CFLAGS=-I/usr/local/include
CONFIG_INST_DATA=/usr/local/share/gdal


--gdal compile problem

After getting build errors about netcdf I added, not removed path to geos_config

./configure  --with-gif=internal --with-jpeg=internal  --enable-shared=no --with-netcdf=no

This did not work so I changed lib and include path tp /opt/local then did CLEAN ALL PROJECTS FOR ALL CONFIGURATIONS and it magically worked, so it is clearly using some other version of gdal from that which I originally built.


Alternative markers options

https://doc.qt.io/qt-5/qsortfilterproxymodel.html#details


Deployment

http://blog.aeguana.com/2015/12/14/how-to-deploy-a-qt-qml-application-on-mac-part-1/
