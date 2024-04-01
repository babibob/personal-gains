# Update all git repos
ls | xargs -P10 -I{} git -C {} pull

# Clone all gitlab projects;
# Need jq git;
# Generate gitlab token for <TOKEN>;
# Find gitlab project number for <NUMBER>
for repo in $(curl -s --header "PRIVATE-TOKEN: <TOKEN>" https://URI/api/v4/groups/<NUMBER> | jq -r ".projects[].web_url"); do git clone $repo; done

# Otherside tips
https://ohshitgit.com/ua