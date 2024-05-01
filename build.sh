rm -rf dist/*
bundle exec jekyll b -d dist
mkdir blog
mv dist/* blog/
mv blog dist
