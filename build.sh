#Clean target directories
rm -rf build/*

#Main
coffee -o build/dist/lib -c coffee
cp -r vendor/* build/dist/lib
cp README.md build/dist/
cp package.json build/dist/
cd build/dist
npm link Scrud
npm update
cd ../..

#unit-test
coffee -o build/unit-test/dist/lib -c unit-test-coffee
cp -r build/dist build/unit-test/
cp -r test-vendor/* build/unit-test/dist/lib
cd build/unit-test/dist/lib
mocha -u tdd PropertyTests
cd ../../../..

#integration-test
coffee -o build/integration-test -c integration-test-coffee
cp -r test-vendor/* build/integration-test
cp test-html/* build/integration-test
cd build/integration-test
npm install sinon
npm link ViewFirstJs
browserify AllTests.js --outfile BrowserTests.js --external underscore --external jquery

cd ../..


