# install packages
install_pkg=$(realpath "./install_pkg.sh")
include_pkg='libc6'
exclude_pkg=''
bash $install_pkg -i -R -d $(realpath 'linglong/sources') -p $PREFIX -I \"$include_pkg\" -E \"$exclude_pkg\"

# build kirigami-addons
cd /project/linglong/sources/kirigami-addons.git
cmake -Bbuild \
      -DCMAKE_INSTALL_PREFIX=build-ins \
      -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib/$TRIPLET
cmake --build build
cmake --install build

# build francis
cd /project/linglong/sources/francis.git
# fix Qml import path
src='./src/main.cpp'
sed -i "/QQmlApplicationEngine engine;/a \    engine.addImportPath(QString(\"/runtime/lib/$TRIPLET/qt5/qml/\"));" $src
sed -i "/QQmlApplicationEngine engine;/a \    engine.addImportPath(QString(\"$PREFIX/lib/$TRIPLET/qt5/qml/\"));" $src
sed -i "/QQmlApplicationEngine engine;/a \    engine.addImportPath(QString(\"$PREFIX/lib/$TRIPLET/qml/\"));" $src
cmake -Bbuild \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_RPATH=$PREFIX/lib/$TRIPLET
cmake --build build
cmake --install build

# fix interpreter
patchelf --set-interpreter "$PREFIX/lib/$TRIPLET/ld-linux-x86-64.so.2" "$PREFIX/bin/francis"
  
# uninstall dev packages
bash $install_pkg -u -r '\-dev'
