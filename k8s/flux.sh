#
flux reconcile hr -n $NS helm-release-name --verbose

flux suspend hr -n $NS helm-release-name
flux resume hr -n $NS helm-release-name

flux get hr -n $NS --status-selector ready=false
