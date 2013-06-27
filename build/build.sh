#Clean target directories
rm -rf ../dist/*

#Build main coffeescript
coffee -o ../dist/js -c ../coffee

#Build test coffeescript
coffee -o ../dist/js -c ../test-coffee

#Copy vendor files in
cp ../vendor/* ../dist/js

r.js -o app.build.js
