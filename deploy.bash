#!/bin/bash
rm -rf ./.demeteorized/
demeteorizer
cp -r ./.demeteorized/* ../d2mpdeploy/
cd ../d2mpdeploy/
git checkout -- programs/server/packages/webapp.js
git add -A
git status
git commit -m "Update"
git push oshift master
cd -
