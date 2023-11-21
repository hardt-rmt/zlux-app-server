#!/bin/sh

################################################################################
# This program and the accompanying materials are made available under the terms of the
# Eclipse Public License v2.0 which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-v20.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Copyright IBM Corporation 2018, 2021
################################################################################

#This file is for installing the pax file of zlux. It lives here so it is covered by source control. It is not called from this location

#********************************************************************
# Expected globals:
# $ZOWE_APIM_ENABLE_SSO
# $CONFIG_DIR
# $ZOWE_ROOT_DIR
# $TEMP_DIR

if [ -z "$ZOWE_ROOT_DIR" ]
then
    echo "Error: script is for internal use only during a zowe install"
    exit 1
fi

umask 0002
COMPONENT_HOME=${ZOWE_ROOT_DIR}/components/app-server

if [ -z $ZWED_INSTALL_DIR ]; then
  ZWED_INSTALL_DIR=${INSTALL_DIR}
fi

# containers only
if [ "${ZWE_RUN_ON_ZOS}" != "true" ]; then
  if [ -f "/component/manifest.yaml" ]; then
    COMPONENT_HOME=/component
  fi
fi


cd ${COMPONENT_HOME}/share
for paxfile in ${ZWED_INSTALL_DIR}/files/zlux/*.pax
do
  if [ ! -f $paxfile ]; then
    echo "No Pax Files"
    break;
  fi
  filename=$(basename $paxfile)
  pluginName="${filename%.*}"
  mkdir $pluginName && cd $pluginName
  echo "Unpax ${paxfile} " >> $LOG_FILE
  pax -r -px -f ${paxfile}
  cd ..
done

cd ${COMPONENT_HOME}/share
tar_path=${ZWED_INSTALL_DIR}/files/zlux
for tarfile in ${tar_path}/*.tar ; do
  if [ ! -f $tarfile ]; then
    echo "No Tar Files"
    break;
  fi
  pluginName=$(basename -- ${tarfile} .tar)
  mkdir -p ${tar_path}/${pluginName}
  echo "Untar ${pluginName} " >> $LOG_FILE
  tar xvf "$tarfile" -C ${tar_path}/${pluginName}
  mv ${tar_path}/${pluginName} .
done

cd ${COMPONENT_HOME}/share/

chtag -tc 1047 ${ZWED_INSTALL_DIR}/files/zlux/config/*.json
chtag -tc 1047 ${ZWED_INSTALL_DIR}/files/zlux/config/plugins/*.json
chmod -R u+w zlux-app-server 2>/dev/null

mkdir -p zlux-app-server/defaults/ZLUX/pluginStorage/org.zowe.zlux.ng2desktop/ui/launchbar/plugins
cp -f ${ZWED_INSTALL_DIR}/files/zlux/config/pinnedPlugins.json zlux-app-server/defaults/ZLUX/pluginStorage/org.zowe.zlux.ng2desktop/ui/launchbar/plugins/
mkdir -p zlux-app-server/defaults/ZLUX/pluginStorage/org.zowe.zlux.bootstrap/plugins
cp -f ${ZWED_INSTALL_DIR}/files/zlux/config/allowedPlugins.json zlux-app-server/defaults/ZLUX/pluginStorage/org.zowe.zlux.bootstrap/plugins/
rm zlux-app-server/defaults/plugins/*
cp -f ${ZWED_INSTALL_DIR}/files/zlux/config/plugins/* zlux-app-server/defaults/plugins
