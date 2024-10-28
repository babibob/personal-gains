# Update all git repos
ls | xargs -P10 -I{} git -C {} pull

# Clone all gitlab projects;
# Dependecies - jq git;
# Generate gitlab token for <TOKEN>;
# Find gitlab project number for <NUMBER>
for repo in $(curl -s --header "PRIVATE-TOKEN: <TOKEN>" https://URI/api/v4/groups/<NUMBER> | jq -r ".projects[].web_url"); do git clone $repo; done


# Resolve git rebae troubles

git checkout master ; \
git pull ; \
git checkout @{-1} ; \
git merge $(git rev-parse master) ; \
git commit -am 'resolve conflict' ;  \
git push origin HEAD

