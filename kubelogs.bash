#!/bin/bash
VERSION="0.2.0"
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

#Get pod names from namespace
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

read -p "Enter directory for output file: " OUTPUT_DIR
while [[ ! -w $OUTPUT_DIR ]] || [[ ! -d $OUTPUT_DIR ]]
do
  printf "Invalid directory or insuficient permissions!\n" >&2
  read -p "Enter directory for output file: " OUTPUT_DIR
done

TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
OUTPUT_NAME="$pod"_"$TIMESTAMP".log
OUTPUT_FILE=$OUTPUT_DIR/$OUTPUT_NAME

kubectl logs --timestamps --namespace=$NAMESPACE $pod > $OUTPUT_FILE || { printf "\nError to save log file!" >&2; exit 1; }
echo "Log file saved in $OUTPUT_FILE"
