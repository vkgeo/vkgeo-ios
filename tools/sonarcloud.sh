#!/bin/sh

PATH=$PATH:~/Qt/5.12.2/ios/bin:~/SonarCloud/build-wrapper-macosx-x86:~/SonarCloud/sonar-scanner-3.3.0.1492-macosx/bin

if [ "$#" = "1" ]; then
    cd .. && \
    mkdir -p .sonarbuild && \
    cd .sonarbuild && \
    qmake ../vkgeo.pro && \
    build-wrapper-macosx-x86 --out-dir bw-output make clean debug-device && \
    cd .. && \
    sonar-scanner -Dsonar.projectKey=vkgeo:vkgeo-ios \
                  -Dsonar.projectName="VKGeo iOS" \
                  -Dsonar.organization=vkgeo-github \
                  -Dsonar.sources=. \
                  -Dsonar.sourceEncoding=UTF-8 \
                  -Dsonar.exclusions="qml/**/*,translations/*" \
                  -Dsonar.cfamily.build-wrapper-output=.sonarbuild/bw-output \
                  -Dsonar.cpp.file.suffixes=.cpp,.mm \
                  -Dsonar.host.url=https://sonarcloud.io \
                  -Dsonar.login="$1"
else
    echo "Syntax: sonarcloud.sh SONARCLOUD_KEY"
fi
