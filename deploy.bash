#!/bin/bash
rm -rf ./.demeteorized/
demeteorizer
rm -rf ../d2mpdeploy/programs/ ../d2mpdeploy/server/
cp -r ./.demeteorized/* ../d2mpdeploy/
cd ../d2mpdeploy/
git add -A
git status
git commit -m "Update"
git push
cd -
