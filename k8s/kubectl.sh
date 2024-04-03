# Aliases for bashrc
alias k="kubectl"
alias h="helm"
alias kns="kubectl config set-context --current --namespace "
alias kube-production="kubectl config use-context production-1"
alias kube-sandbox="kubectl config use-context sandbox-1"
alias kube-agent-prod="kubectl config use-context production-agents-1 "
alias kube-agent-sand="kubectl config use-context stage-agents-1"
alias kube-get="kubectl config get-contexts"

$NS = <needed_namespace>
# Scale pods in deployment from 0 to 1
k -n $NS get deploy | \
grep '0/0' | \
awk '{print $1 }' | \
xargs -I line kubectl -n $NS patch deploy line --type json -p='[{"op": "replace", "path": "/spec/replicas", "value":1}]'

# Recreate staetfullset with pvc
k -n $NS scale sts <STS-NAME>  --replicas=0 ; \
k -n $NS delete pvc <PVC-NAME> -0 <PVC-NAME> -1 <PVC-NAME> -2 ; \
k -n $NS scale sts <STS-NAME>  --replicas=3

# Disable cronjob
k -n $NS patch cj <CJ_NAME> --type json -p='[{"op": "replace", "path": "/spec/suspend", "value":true}]'

# Show pods with STATUS != Running
k -n $NS get po --field-selector status.phase!=Running | grep -v NAME -A 0 | awk '{print $1}'

# Delete pods with STATUS == Crash
k -n $NS get pods | grep Crash | awk '{print $1}' | xargs kubectl -n $NS delete pod

# Get all <NAME> pods in line, separeted by space
k -n $NS get pods | grep <NAME> | cut -d' ' -f1 | tr '\n' ' '

# Clean replicasets without deployment
k -n $NS delete rs $(k -n $NS get rs -o jsonpath='{ .items[?(@.spec.replicas==0)].metadata.name }')

# Node utilization
k top node

# Change count of replicas in all deployment with labes <LABEL>
k -n $NS scale deploy -l app.kubernetes.io/instance=<LABEL> --replicas 0

# Delete pods by selector <SELECTOR>
k -n $NS get rs --selector=app.kubernetes.io/instance=<SELECTOR>

# Pods on the nodes A|B|C|D
k get po -A -o wide | grep -E 'A|B|C|D'

# Node hostname by specific label
k get node -o json | jq '.items[].metadata.labels | select(."topology.kubernetes.io/zone"|test("ru-central1-[a|b]")) | ."kubernetes.io/hostname"'

# Resources on node <NODE_NAME>
k describe node NODE_NAME | grep Allocated -A 5 | tail -n2 | awk '{print $2}'

# Utilazation resources on the node <NODE_NAME>
k describe node NODE_NAME | grep Allocatable -A 5 | grep 'cpu\|memory' | awk '{print $2}'

# Resources nodes in the cluster
k get node -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.allocatable.cpu}{" "}{.status.allocatable.memory}{"\n"}{end}'
# OR wrong way :)
for nodename in $(k get node | grep -v NAME -A 0 | awk '{print $1}'); \
    do str=$((str+1)) && echo $str && kubectl get node $nodename -o jsonpath='{range .status.allocatable}{.cpu}{" "}{.memory}{end}' && echo " $nodename";\
done;

# Otherside tips
## short list of commands
https://gist.github.com/kevsersrca/3338725493ba24d29164dde8c0114da4
## Quick Reference
https://kubernetes.io/docs/reference/kubectl/quick-reference/
## Commands examples
https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
## Another examples
https://jamesdefabia.github.io/docs/user-guide/kubectl/kubectl_run/
## Quick Answers
https://www.grepper.com/answers/406309/kubectl+get+taints
