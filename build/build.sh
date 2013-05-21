

#Clean target directories
rm -rf ../js/*
rm -rf ../test-js/*
rm -rf ../lib/*
rm -rf ../dist/*
mvn -f ../pom.xml clean

#Build main coffeescript
coffee -o ../js -c ../coffee

#Build test coffeescript
coffee -o ../test-js -c ../test-coffee

#Copy all of it together under lib including vendor files
cp ../js/* ../lib/
cp ../test-js/* ../lib/
cp ../vendor/* ../lib/


r.js -o app.build.js

#Run the maven build for substeps test in the dist directory
mvn -f ../dist/pom.xml install
