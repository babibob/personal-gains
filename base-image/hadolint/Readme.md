### ANSIBLE linter
``` shell
if [ -d ansible ] ;
    then
        ls -laR ${CI_PROJECT_DIR}/ansible/*.yml ;
        echo ${PWD} ;
        cp -v /opt/ansible/.ansible-lint.yml   ${PWD}/ansible-lint.yaml ;
        ansible-lint -c ${PWD}/ansible-lint.yaml --force-color ${CI_PROJECT_DIR}/ansible/*.yml ;
    else
        echo 'Project has bad structure' ;
fi
```

### YAML linter
``` shell
yamllint -f colored .
```

### Docker linter
``` shell
find . -type f -name *Dockerfile* -print -exec hadolint --no-fail --info SC2174 --info DL3018 --info DL3008 --info DL3013 '{}' + #|| true
```