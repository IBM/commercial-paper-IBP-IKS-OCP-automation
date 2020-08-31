#!/usr/bin/env bash
#
# SPDX-License-Identifier: Apache-2.0
#
set -ex
# use it one by one
ansible-playbook 97-delete-endorsing-organization-components.yml --extra-vars '{"import_export_used":true}'
ansible-playbook 98-delete-endorsing-organization-components.yml --extra-vars '{"import_export_used":true}'
ansible-playbook 99-delete-ordering-organization-components.yml --extra-vars '{"import_export_used":true}'
