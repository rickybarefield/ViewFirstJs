#Clean target directories
rm -rf dist/*

#Main
coffee -o dist/js -c coffee
cp -r vendor/* dist/js

cd dist
npm install requirejs
npm install sinon
cd js
browserify ViewFirst.js --outfile ../ViewFirst-0.1.js --external "./Scrud.js"  --require "./Scrud.js:underscore" --external "underscore" --external "jquery/dist/jquery"

#Test
cd ../..
coffee -o dist/test-js -c test-coffee
cp -r test-vendor/* dist/test-js
cd dist/test-js
cp ../ViewFirst-0.1.js .

browserify AllTests.js --outfile ../AllTests.js --external "./ViewFirst-0.1.js" --require "./ViewFirst-0.1.js"

cd ../..


