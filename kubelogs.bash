#!/bin/bash
VERSION="0.1.0-beta"
DEFAULT_NAMESPACE="default"


USAGE="kubelogs [-h] [-n] [-v] -- dump kubernetes pod logs
Options:
    -h, --help           Show this help text
    -n, --namespace      The Kubernetes namespace where the pods are located (defaults to $DEFAULT_NAMESPACE)
    -v, --version        Prints the kubelogs version"

if [ "$#" -ne 0 ]; then
	while [ "$#" -gt 0 ]
	do
		case "$1" in
		-h|--help)
			echo "$USAGE"
			exit 0
			;;
		-v|--version)
			echo "$VERSION"
			exit 0
			;;
    -n|--namespace)
    			if [ -z "$2" ]; then
    				NAMESPACE="$DEFAULT_NAMESPACE"
    			else
    				NAMESPACE="$2"
    			fi
    			;;
          --)
      			break
      			;;
      		-*)
			       echo "Invalid option '$1'. Use --help to see the valid options" >&2
			exit 1
			;;
		# an option argument, continue
		*)  ;;
		esac
		shift
	done
fi

if [[ -z "$NAMESPACE" ]]; then NAMESPACE="$DEFAULT_NAMESPACE"; fi

#Get pods name from namespace
POD_LIST=(`kubectl get pods --namespace=$NAMESPACE --output=jsonpath='{.items[*].metadata.name}'`)

if [[ -z ${POD_LIST[@]} ]]; then echo "No pods found for namespace $NAMESPACE"; exit; fi

echo "Choose a pod:"
PS3='Pod: '

select pod in "${POD_LIST[@]}" "Cancel"
do
  if [[ ! -z $pod ]] && [[ $pod != "Cancel" ]]; then
    POD_SELECTED=$pod
    echo "Pod selected is $POD_SELECTED"
    break
  elif [[ $pod = "Cancel" ]]; then
    echo "Bye!"
    exit
  else
    echo "Invalid Pod!"
  fi
done
