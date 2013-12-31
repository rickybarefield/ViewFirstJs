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
coffee -o build/test -c test-coffee
cp -r test-vendor/* build/test
cp test-html/* build/test
cd build/test

npm install sinon
npm link ViewFirstJs
browserify AllTests.js --outfile BrowserTests.js --external underscore --external jquery

cd ../..


