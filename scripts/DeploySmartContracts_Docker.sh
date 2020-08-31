#!/usr/bin/env bash
set -x
cd "$(dirname "$0")"
function usage {
    echo "Usage: build_network.sh [-i] [-v] [build|destroy]" 1>&2
    exit 1
}
while getopts ":vp:" OPT; do
    case ${OPT} in
        p)
            PASSWORD_FILE=$OPTARG
            ;;
        v)
            VERBOSE_RUN="-vvv"
            ;;
        \?)
            usage
            ;;
    esac
done
shift $((OPTIND -1))
set -x
docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/18-install-chaincode.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
if [ $? -eq 2 ]
then
echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
exit 2
fi
docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/19-install-chaincode.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
if [ $? -eq 2 ]
then
echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
exit 2
fi
docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/20-instantiate-chaincode.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
if [ $? -eq 2 ]
then
echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
exit 2
fi

