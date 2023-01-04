#!/bin/sh
echo "Deploying chart in $PWD ..."
helm package .
for tar in $(find $PWD -name '*.tgz'); do curl -X POST --data-binary "@$tar" http://localhost:8080/chartmuseum/api/charts; done
rm -rf $PWD/*.tgz
