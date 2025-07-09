# Show hr without "Release reconciliation succeeded" 
k -n $NS get helmreleases.helm.toolkit.fluxcd.io -o wide | grep -v 'Release reconciliation succeeded'
k get hr -A | grep -i failed

# 
helm -n $NS history $HR

helm -n $NS ls -a

helm -n $NS get manifest $HR
