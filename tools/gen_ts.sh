#!/bin/sh

PATH=$PATH:~/Qt/5.12.8/ios/bin

lupdate -locations absolute ../vkgeo.pro -ts ../translations/vkgeo_ru.src.ts
lupdate -locations absolute ../qml       -ts ../translations/vkgeo_ru.qml.ts

lconvert ../translations/vkgeo_ru.src.ts ../translations/vkgeo_ru.qml.ts ../translations/vkgeo_ru.qt.ts -o ../translations/vkgeo_ru.ts
