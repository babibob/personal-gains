# Show hr without "Release reconciliation succeeded" 
k -n $NS get helmreleases.helm.toolkit.fluxcd.io -o wide | grep -v 'Release reconciliation succeeded'

# 