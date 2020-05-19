cd blog_src

export DEV=0
npm run export

rm -r ../blog
mkdir -p ../blog

cp -a __sapper__/export/* ../blog

echo "BUILD DONE!"
