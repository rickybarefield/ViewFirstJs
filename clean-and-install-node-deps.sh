#!/bin/sh
#Clean target directories
rm -rf build/*

mkdir build/dist
cd build/dist
npm link Scrud
npm install underscore
npm install jquery@2.1.0-beta3
cd ../..

mkdir build/unit-test
cd build/unit-test
npm install proxyquire
npm install sinon
cd ../..

mkdir build/integration-test
cd build/integration-test
npm install sinon
cd ../..