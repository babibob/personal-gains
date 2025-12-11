# Update all git repos
ls | xargs -P10 -I{} git -C {} pull
# OR
find . -type d -name ".git" -execdir sh -c 'echo "#### Updating $(pwd) "####"; git pull' \;

# Clone all gitlab projects;
# Dependecies - jq git;
# Generate gitlab token for <TOKEN>;
# Find gitlab project number for <NUMBER>
for repo in $(curl -s --header "PRIVATE-TOKEN: <TOKEN>" https://URI/api/v4/groups/<NUMBER> | jq -r ".projects[].web_url"); 
  do git clone $repo; 
  done

# Resolve git rebase conflicts
export BRANCH=$(git symbolic-ref --short refs/remotes/origin/HEAD | awk -F'/' '{print $2}') ; \
git checkout ${BRANCH} ; \
git pull ; \
git checkout @{-1} ; \
git merge $(git rev-parse ${BRANCH}) ; \
git commit -am 'resolve conflict' ;  \
git push origin HEAD

