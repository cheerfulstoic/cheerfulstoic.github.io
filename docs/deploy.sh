JEKYLL_ENV=production jekyll build

git add docs
git add _posts

git commit -m "Deploy"
git push
