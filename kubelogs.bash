#!/usr/bin/env bash
VERSION="0.2.1"

USAGE="kubelogs [-h] [-n] [-v] -- dump kubernetes pod logs to local file
Options:
    -h, --help           Show this help text
    -n, --namespace      The Kubernetes namespace to list pods. If empty list available namespaces
    -v, --version        Prints the kubelogs version"

function select_namespace() {
  #Get namespace names for current context
  NAMESPACE_LIST=(`kubectl get namespaces --output=jsonpath='{.items[*].metadata.name}'`)

  if [[ -z ${NAMESPACE_LIST[@]} ]]; then echo "No namespaces found for this context!" >&2; exit 1; fi

  echo "Choose a namespace:"
  PS3='Namespace: '
  select option in "${NAMESPACE_LIST[@]}" "CANCEL"
  do
    if [[ ! -z $option ]] && [[ $option != "CANCEL" ]]; then
      NAMESPACE=$option
      echo "Namespace selected is $NAMESPACE"
      break
    elif [[ $option = "CANCEL" ]]; then
      echo "Bye!"
      exit
    else
      echo "Invalid namespace!"
    fi
  done
}

function select_pod() {
  #Get pod names from namespace
  POD_LIST=(`kubectl get pods --namespace=$NAMESPACE --output=jsonpath='{.items[*].metadata.name}'`)

  if [[ -z ${POD_LIST[@]} ]]; then echo "No pods found for namespace $NAMESPACE!" >&2; exit 1; fi

  echo "Choose a pod:"
  PS3='Pod: '
  select option in "${POD_LIST[@]}" "CANCEL"
  do
    if [[ ! -z $option ]] && [[ $option != "CANCEL" ]]; then
      POD=$option
      echo "Pod selected is $POD"
      break
    elif [[ $option = "CANCEL" ]]; then
      echo "Bye!"
      exit
    else
      echo "Invalid Pod!"
    fi
  done
}

#TODO: A function to get containers from selected pod
#function select_containers() {
#
#}

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
            select_namespace #Call select_namespace if parameter --namespace is empty
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


if [[ -z "$NAMESPACE" ]]; then select_namespace; fi #Call select_namespace function if $NAMESPACE is empty

select_pod #Call select_pod function

read -p "Enter a local directory for output file: " OUTPUT_DIR
while [[ ! -w $OUTPUT_DIR ]] || [[ ! -d $OUTPUT_DIR ]]
do
  printf "Invalid directory or insuficient permissions!\n" >&2
  read -p "Enter a local directory for output file: " OUTPUT_DIR
done

TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
OUTPUT_NAME="$POD"_"$TIMESTAMP".log
OUTPUT_FILE=$OUTPUT_DIR/$OUTPUT_NAME

#Get logs from pod and save to local file
kubectl logs --timestamps --namespace=$NAMESPACE $POD > $OUTPUT_FILE || { printf "\nError to get log content!" >&2; exit 1; }
echo "Log file saved in $OUTPUT_FILE"
