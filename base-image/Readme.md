### Run python script in playbook
``` yaml
- name: Run python
  command:
    chdir: /path/to/script
    cmd: "{{ discovered_interpreter_python }} script.py"
```
