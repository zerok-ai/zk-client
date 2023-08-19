#!/bin/bash
THIS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

helpFunction()
{
    echo -e "        👉 Usage:
        -----------------------------------
        $0 -p root password for DB"
   echo ""
   exit 1 # Exit script after printing help
}

while getopts "p:" opt; do
   case "$opt" in
      p )
        passwd=$OPTARG
        ;;
      ? ) helpFunction
        ;;
   esac
done


if  [[ -z $passwd ]]; then
    echo "invalid input. ERR #4.1"
fi

echo "checking helm binary"
if ! helm version; then
    echo "helm not available. ERR #4.2"
    exit 1
else
    echo "helm binary found."
fi

helm dependency update $THIS_DIR/db-helm-charts
#helm --install $APP_NAME $THIS_DIR/db-helm-charts/ --create-namespace --namespace zk-client
helm --set=postgresql.global.postgresql.auth.postgresPassword="$passwd" upgrade "$APP_NAME" --install $THIS_DIR/db-helm-charts/ --create-namespace --namespace zk-client --wait



