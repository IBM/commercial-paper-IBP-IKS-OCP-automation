#!/usr/bin/env bash
set -x
cd "$(dirname "$0")"
IMPORT_EXPORT_REQUIRED=0
function usage {
    echo "Usage: build_network.sh [-i] [-v] [build|destroy]" 1>&2
    exit 1
}
while getopts ":ivp:" OPT; do
    case ${OPT} in
        i)
            IMPORT_EXPORT_REQUIRED=1
            ;;
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
COMMAND=$1
if [ "${COMMAND}" = "build" ]; then
    set -x
    docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/11-create-endorsing-organization-components.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
    if [ $? -eq 2 ]
    then
    echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
    exit 2
    fi
    if [ "${IMPORT_EXPORT_REQUIRED}" = "1" ]; then
        docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/12-export-organization.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
        if [ $? -eq 2 ]
        then
        echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
        exit 2
        fi
        docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/13-import-organization.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
        if [ $? -eq 2 ]
        then
        echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
        exit 2
        fi
    fi
    docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/14-add-organization-to-channel.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
    if [ $? -eq 2 ]
    then
    echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
    exit 2
    fi
    if [ "${IMPORT_EXPORT_REQUIRED}" = "1" ]; then
        FAIL_REASON=$(docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/15-import-ordering-service.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE | grep -c 'Ordering service exists and appears to be managed by this console, refusing to continue')
        if [ $? -eq 2 ]
        then
        #echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
        #exit 2
            if [ $FAIL_REASON -eq 0 ]
            then
            echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
            exit 2
            fi
        fi
    fi
    docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/16-join-peer-to-channel.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
    if [ $? -eq 2 ]
    then
    echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
    exit 2
    fi
    docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/17-add-anchor-peer-to-channel.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
    if [ $? -eq 2 ]
    then
    echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
    exit 2
    fi
    docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/18-install-chaincode.yml  $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
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
    set +x
elif [ "${COMMAND}" = "destroy" ]; then
    set -x
    if [ "${IMPORT_EXPORT_REQUIRED}" = "1" ]; then
        docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/97-delete-endorsing-organization-components.yml --extra-vars '{"import_export_used":true}' $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
        if [ $? -eq 2 ]
        then
        echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
        exit 2
        fi
        docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/98-delete-endorsing-organization-components.yml --extra-vars '{"import_export_used":true}' $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
        if [ $? -eq 2 ]
        then
        echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
        exit 2
        fi
        docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/99-delete-ordering-organization-components.yml --extra-vars '{"import_export_used":true}' $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
        if [ $? -eq 2 ]
        then
        echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
        exit 2
        fi
    else
        docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/97-delete-endorsing-organization-components.yml $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
        if [ $? -eq 2 ]
        then
        echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
        exit 2
        fi
        docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/98-delete-endorsing-organization-components.yml $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
        if [ $? -eq 2 ]
        then
        echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
        exit 2
        fi
        docker run --rm -v $PWD:/playbooks mydockerorg/ansible ansible-playbook /playbooks/99-delete-ordering-organization-components.yml $VERBOSE_RUN --vault-password-file $PASSWORD_FILE
        if [ $? -eq 2 ]
        then
        echo "Failure: PLAYBOOK EXECUTION FAILED. ABORTING." >&2
        exit 2
        fi
    fi
    set +x
else
    usage
fi