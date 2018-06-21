#!/bin/bash

set -e

version=$1
factorio=$2

[ -z "$version" ] && (echo "expected version" 1>&2; exit 1)
[ -z "$factorio" ] && (echo "expected factorio path" 1>&2; exit 1)

sed -r "s/VERSION/${version}/" templates/info.json > info.json

rm -f migrations/*.lua
cp templates/update-techs-recipes.lua migrations/${version}-techs-recipes.lua

mod="logicarts_${version}"

rm -rf $factorio/mods/logicarts*
cp -r $(pwd) $factorio/mods/$mod

pushd $factorio/mods
zip -r $mod.zip $mod
rm -rf $mod
popd
