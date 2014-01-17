#!/bin/sh
#Clean target directories
rm -rf build/*

mkdir build/dist
cd build/dist
npm link Scrud
cd ../..

mkdir build/unit-test
npm install proxyquire

mkdir build/integration-test
cd build/integration-test
npm install sinon
cd ../..