JEKYLL_ENV=production jekyll build

git add docs
git commit -m "Deploy"
git push
