#!/usr/bin/env bash
#
# SPDX-License-Identifier: Apache-2.0
#
set -ex

ansible-playbook 18-install-chaincode.yml
ansible-playbook 19-install-chaincode.yml
ansible-playbook 20-instantiate-chaincode.yml
ansible-playbook 21-register-application.yml
ansible-playbook 22-register-application.yml
