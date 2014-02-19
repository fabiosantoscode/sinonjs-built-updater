#!/usr/bin/env bash

npm install

if [ ! -z "$update_sinon_ruby" ]; then
    update_sinon_ruby=ruby
fi

if [ -d "./node_modules/buster-format" ]; then 
    echo "Buster-format exists in expected dir. skipping install"
else
    npm install buster-format
fi

rm -rf sinon-built

[ ! -d "./sinon-built" ] && git clone git@github.com:fabiosantoscode/sinon-built.git --quiet

cd sinon-built


rm -rf node_modules/buster-format
mkdir -p node_modules/buster-format
cp -r ../node_modules/buster-format/* ./node_modules/buster-format

git remote add upstream git@github.com:cjohansen/Sinon.JS.git > /dev/null &> /dev/null
git remote update upstream &> /dev/null > /dev/null

git tag | grep "v.\\+" | cat | while read line;
do
    node -e "process.exit(require('semver').lt('1.7.4', '$line') ? 0 : 1)"
    if [ $? -eq 0 ]; then
        git checkout $line -B built-temp > /dev/null

        if [ -d "pkg" ]; then
            echo "* not building $line. pkg dir exists."
        else
            echo "## building $line"

            $update_sinon_ruby ./build
            git add -f pkg
            git commit -m "buildscript" --quiet

            git tag -f $line
            git push origin $line
            git rm -rf pkg
            echo "built $line successfully"
        fi

        echo ""
    fi
done

