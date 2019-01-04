##############################################################################
#
# Tool to add native AD IDP for SSO - LINUX
#
# Copyright 2015 VMware, Inc.  All rights reserved. VMware Confidential
#
# [AUTHOR] : Balaji Boggaram Ramanarayan
# [VERSION] : SSO 2.0
# [USAGE] :
#      Syntax : sso-add-native-ad-idp.sh <Native-Active-Dir-Domain-Name>
#      Example : sso-add-native-ad-idp.sh example.com
##############################################################################

#!/bin/bash
echo  "Starting to add Native Active directory as Identity Source"
VMIDENTITY_SCRIPTS_DIR=/usr/lib/vmidentity/tools/scripts
sso_import_loc="/usr/lib/vmidentity/tools/scripts"

# Delete exported property file if it exists already
if [ -f ${VMIDENTITY_SCRIPTS_DIR}/exported_sso.properties ]
then
    echo "The exported_sso.properties file already exists. Hence, deleting it"
    rm ${VMIDENTITY_SCRIPTS_DIR}/exported_sso.properties
fi

# Write exported domain properties to a new exported_sso.properties file
cat <<EOT >> ${VMIDENTITY_SCRIPTS_DIR}/exported_sso.properties
ExternalIdentitySource.$1.name=$1
ExternalIdentitySource.$1.type=0
ExternalIdentitySourcesDomainNames=$1
EOT

# Invoke sso_import to add native active directory
${sso_import_loc}/sso_import.sh

# Delete the exported properties file after operation completed.
rm -f ${VMIDENTITY_SCRIPTS_DIR}/exported_sso.properties