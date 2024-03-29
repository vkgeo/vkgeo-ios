#!/bin/sh

NUMBER_OF_PROCESSORS=$(sysctl -n hw.ncpu)

PATH="$PATH:$HOME/Qt/5.12.11/ios/bin:$HOME/SonarCloud/build-wrapper-macosx-x86:$HOME/SonarCloud/sonar-scanner-4.3.0.2102-macosx/bin"

if [ "$#" = "1" ]; then
    cd .. && \
    mkdir -p .sonarbuild && \
    cd .sonarbuild && \
    ([ -d bw-output ] && rm -r bw-output || true) && \
    ([ -f Makefile ] && make distclean || true) && \
    qmake ../vkgeo.pro && \
    build-wrapper-macosx-x86 --out-dir bw-output make -j$NUMBER_OF_PROCESSORS debug-device && \
    cd .. && \
    sonar-scanner -Dsonar.projectKey=vkgeo_vkgeo-ios \
                  -Dsonar.projectName="VKGeo iOS" \
                  -Dsonar.organization=vkgeo-github \
                  -Dsonar.sources=. \
                  -Dsonar.sourceEncoding=UTF-8 \
                  -Dsonar.exclusions="qml_*.cpp,qrc_*.cpp,3rdparty/**/*,ios/frameworks/**/*,qml/**/*,translations/*" \
                  -Dsonar.cfamily.build-wrapper-output=.sonarbuild/bw-output \
                  -Dsonar.cfamily.cache.enabled=false \
                  -Dsonar.cfamily.threads=$NUMBER_OF_PROCESSORS \
                  -Dsonar.cpp.file.suffixes=.cpp,.mm \
                  -Dsonar.host.url=https://sonarcloud.io \
                  -Dsonar.login="$1"
else
    echo "Syntax: sonarcloud.sh SONARCLOUD_KEY"
fi
