#!/bin/bash
#
# Purpose: Entrypoint for AVD Demo container
#
# Author: @titom73
# Date: 2020-10-26
# Version: 0.2
# License: BSD
# --------------------------------------

# Builder variables
# Protected var if not set in K8S specs:
# - name: REPO_AVD_DATA
#   value: "https://github.com/inetsix/avd-for-compose-kubernetes-demo.git"
# - name: ANSIBLE_PLAYBOOK
#   value: "dc1-fabric-deploy-cvp.yml"
# - name: ANSIBLE_TAGS
#   value: "build"

if [[ -z REPO_AVD_DATA ]]; then
    export REPO_AVD_DATA='https://github.com/arista-netdevops-community/avd-for-compose-kubernetes-demo.git'
else
    echo 'REPO_AVD_DATA is set from outside with: '${REPO_AVD_DATA}
fi

if [[ -z ANSIBLE_TAGS ]]; then
    export ANSIBLE_TAGS="build"
fi

if [[ -z ANSIBLE_PLAYBOOK ]]; then
    export ANSIBLE_PLAYBOOK="dc1-fabric-deploy-cvp.yml"
fi

# Local binaries
export MOUNT_FOLDER='/projects'
export GIT_BIN=$(which git)
export PIP_BIN=$(which pip3)
export ANSIBLE_PLAYBOOK_BIN=$(which ansible-playbook)

cd ${MOUNT_FOLDER}

if [ -d .git ]; then
  echo 'Repo already there, pulling out new version'
  ${GIT_BIN} fetch origin
  ${GIT_BIN} pull origin
else
  echo 'Cloning repository ...'
  ${GIT_BIN} clone ${REPO_AVD_DATA} .
fi;

if [ -f requirements.txt ]; then
  echo 'Found additional requirements, installing ...'
  ${PIP_BIN} install -r requirements.txt
fi;

ansible-galaxy collection install arista.cvp
ansible-galaxy collection install arista.avd

echo '* Checking playbook sanity'
${ANSIBLE_PLAYBOOK_BIN} ${ANSIBLE_PLAYBOOK} --syntax-check

echo '* Building configuration and documentation'
${ANSIBLE_PLAYBOOK_BIN} ${ANSIBLE_PLAYBOOK} --tags ${ANSIBLE_TAGS}

echo '* Building documentation'
if [[ -f medias/stylesheet.css ]]; then
  cp -r medias/stylesheet.css documentation/
fi;
mkdocs build -f mkdocs.yml
mv site/* /web/

echo '* Infinite wait...'
tail -f /dev/null
