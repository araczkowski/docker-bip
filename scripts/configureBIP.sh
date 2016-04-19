#!/bin/bash
#
# $Header: xdo/app/install/standalone/wls/configureBIP.sh /bipub_11.1.1.7.0/2 2013/04/05 12:37:06 syoshida Exp $
#
# configureBIP.sh
#
# Copyright (c) 2012, 2013, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      configureBIP.sh
#
#    DESCRIPTION
#      This script is used to setup BI Publisher and WebLogic Server.
#
#    NOTES
#
#
#    MODIFIED   (MM/DD/YY)
#    syoshida    04/20/12 - Creation
#

BIP_HOME="$(cd $(dirname $0) && pwd)"
export BIP_HOME

. ./bin/setBIPEnv.sh

UPDATE_PASSWD=true
DOMAIN_TARGET_SCRIPT="bipdomain_script"

if [ -n "${WLS_ADMIN_PWD}" ] ; then
  UPDATE_PASSWD=false
fi

if [ ${UPDATE_PASSWD} = "true" ] ; then
  echo "***************************************************"
  echo "*  Set Administrator Username and Password:       *"
  echo "*                                                 *"
  echo "*  Use this account to manage WebLogic and        *"
  echo "*  BI Publisher.                                  *"
  echo "*                                                 *"
  echo "*  Username should not include special characters *"
  echo "*  Password must be at least 8 characters long    *"
  echo "*  and include at least one alpha character and   *"
  echo "*  at least one number.                           *"
  echo "***************************************************"
WLS_ADMIN_USER=admin
WLS_ADMIN_PWD=admin123
WLS_ADMIN_PWD2=admin123


  if [ -z "${WLS_ADMIN_USER}" ] ; then
    echo "Userid should not be null. Please try again."
    exit 1
  fi

  if [ "${WLS_ADMIN_PWD}" != "${WLS_ADMIN_PWD2}" ] ; then
    echo "Passwords do not match. Please try again."
    exit 1
  fi

  if [ -z "${WLS_ADMIN_PWD}" ] ; then
    echo "Password should not be null. Please try again."
    exit 1
  fi

  p_len=${#WLS_ADMIN_PWD}
  if [ "${p_len}" -lt "8" ] ; then
     echo "Password must be at least 8 characters long. Please try again."
     exit 1
  fi

  p_alpha=`echo ${WLS_ADMIN_PWD} | grep -e '[A-Za-z]'`
  if [ -z "${p_alpha}" ] ; then
     echo "Password must include at least one alphabet character. Please try again."
     exit 1
  fi

  p_num=`echo ${WLS_ADMIN_PWD} | grep -e '[0-9]'`
  if [ -z "${p_num}" ] ; then
     echo "Password must include at least one number character. Please try again."
     exit 1
  fi
fi

export WLS_ADMIN_USER
export WLS_ADMIN_PWD

# Setup the WLS environment
. ${MW_HOME}/wlserver/server/bin/setWLSEnv.sh

# Generate .product.properties and the registry.xml required for configuration
# provisioning
${JAVA_HOME}/bin/java -Dant.home=${MW_HOME}/modules/org.apache.ant_1.7.1 \
  org.apache.tools.ant.Main -f ${MW_HOME}/configure.xml

if [ $? == "1" ] ; then
   echo "Failed to configure BI Publisher."
   exit 1
fi

# Configure scripts to create bip domain
TEMPLATE_PATH=${BIP_HOME}/install/bipdomain.jar
export TEMPLATE_PATH
${JAVA_HOME}/bin/java -Dant.home=${MW_HOME}/modules/org.apache.ant_@ANT_VERSION@ \
  org.apache.tools.ant.Main -f ${BIP_HOME}/install/bip_install.xml ${DOMAIN_TARGET_SCRIPT}

JAVA_OPTIONS="${USER_MEM_ARGS} ${JAVA_OPTIONS}"

${MW_HOME}/wlserver/common/bin/wlst.sh -i ${BIP_HOME}/bipdomain_script.txt

if [ $? = 1 ] ; then
  echo "Failed to deploy BI Publisher."
  rm ${BIP_HOME}/bipdomain_script.txt > /dev/null
  exit 1;
fi

rm ${BIP_HOME}/bipdomain_script.txt

${BIP_HOME}/bin/createUser.sh ${WLS_ADMIN_USER} ${WLS_ADMIN_PWD} XMLP_ADMIN
if [ $? == "1" ] ; then
   echo "Failed to create BI Publisher Administrator account."
   exit 1
fi

# Configure WLS Administrator
rm -f ${DOMAIN_HOME}/security/DefaultAuthenticatorInit.ldift

${JAVA_HOME}/bin/java weblogic.security.utils.AdminAccount ${WLS_ADMIN_USER} ${WLS_ADMIN_PWD} ${DOMAIN_HOME}/security

BOOT_FILE="${DOMAIN_HOME}/servers/bipserver/security/boot.properties"
echo "username=${WLS_ADMIN_USER}" > ${BOOT_FILE}
echo "password=${WLS_ADMIN_PWD}" >> ${BOOT_FILE}

# Add User profile
LOWER_CASE_USER_NAME=`echo ${WLS_ADMIN_USER} |tr '[A-Z]' '[a-z]'`
USER_FOLDER="${BIP_HOME}/repository/Users/~${LOWER_CASE_USER_NAME}"
mkdir -p ${USER_FOLDER}
cp -f "${BIP_HOME}/install/user~.profile" ${USER_FOLDER}
