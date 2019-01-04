#!/bin/bash

IDM_LIBDIR=/opt/vmware/lib64
TOOL_LIBDIR=$( v=$(readlink "$0") && echo $(dirname "$v") || echo $(dirname "$0") )
COMMON_LIBDIR=/usr/lib/vmware-sso/commonlib

TOOL_CLASSPATH="$TOOL_LIBDIR/migrationtool.jar:$TOOL_LIBDIR/exporttool.jar"
TOOL_CLASSPATH="$TOOL_CLASSPATH:$IDM_LIBDIR/*"
LS_CLASSPATH="$IDM_LIBDIR/lookupservice-installer.jar"
LS_CLASSPATH="$LS_CLASSPATH:$IDM_LIBDIR/*:$COMMON_LIBDIR/*"


: ${SSO_EXPORT_DATAFILE:="$TOOL_LIBDIR/exported_sso.properties"}

/usr/java/jre-vmware/bin/java -cp "$TOOL_CLASSPATH" -ea \
   com.vmware.identity.migration.ImporterToSSO2 "$SSO_EXPORT_DATAFILE" localhost

