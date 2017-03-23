#!/bin/ksh
#######################################################################################################################
#### Script name  : BudgetAuthPurge.sh
#### Purpose	  : Archive and Purges BUDGET_AUTH records for a given reporting center (or ALL reporting centers) and fiscal year.
####              : This will be a 3 step process.  Steps are Archive, Verify and Purge
#### Author 	  : Jim Stangl
#### Version      : Init 1.0
#### Date created : March 8, 2017
####
#######################################################################################################################

BudgetAuthPurgeUsageMessage () {

clear

print "
Program: Budget_Auth Purge
Archive and purge BUDGET_AUTH records for a given reporting center (or ALL reporting centers) and fiscal year.
This is a three step process.  Steps are Archive, Verify and Purge and specified in parameter.
Archive Repository:  REPL instance, ISRSARC Schema.
Usage: ${1##*/}
        -r Reporting center
        -y Fiscal Year
	-c commit/rollback flag
	-s step
	[-?v]
    	[-n]
  Where:
    -r = Reporting center [XXXX or ALL - all reporting centers]
    -y = Fiscal Year [ccyy format]
    -c = commit/rollback flag [Y = commit, N = rollback]
    -s = Step number [1 = Archive, 2 = Verify, 3 = Purge] or ALL
    -v = Verbose Mode - debug output displayed
    -n = Syntax Mode - Checks for syntax errors without executing the script
    -h = Help - display this message
Example:
        ksh /apps/isrs/script/BudgetAuthPurge.sh -r 0070 -y 2007 -c Y -s ALL
"
}

#### ISRS Setup

. /apps/isrs/script/isrssetup.sh

#######################################################################################################################

VERSION="1.0"
TRUE="1"
FALSE="0"

BudgetAuthPurgeReportingCenter=""
BudgetAuthPurgeFiscalYear=""
BudgetAuthPurgeCommit="Y"
BudgetAuthPurgeStep=""
BudgetAuthPurgeDebug="${FALSE}"
BudgetAuthPurgeSyntax="${FALSE}"
BudgetAuthPurgeMessageFileLocation=""
BudgetAuthPurgeSpoolFile="/tmp/BudgetAuthPurge_Messages.txt"
BudgetAuthPurgeReportingCenterValid="${FALSE}"
GenericJobOptionsAndParameters="${@}"
GenericJobTag="budget_auth_purge"

#### define variables to convert lowercase (-l) / uppercase (-u) automatically with typeset command

typeset -u BudgetAuthPurgeReportingCenter=""
typeset -u BudgetAuthPurgeCommit=""
typeset -u BudgetAuthPurgeStep=""

#######################################################################################################################
#### Process the command line options and arguments.

while getopts ":r:y:c:s:vn" BudgetAuthPurgeOptions
 
do
  case "${BudgetAuthPurgeOptions}" in
        'r') BudgetAuthPurgeReportingCenter="${OPTARG}";;
        'y') BudgetAuthPurgeFiscalYear="${OPTARG}";;
        'c') BudgetAuthPurgeCommit="${OPTARG}";;
        's') BudgetAuthPurgeStep="${OPTARG}";;
        'v') BudgetAuthPurgeDebug="${TRUE}";;
        'n') BudgetAuthPurgeSyntax="${TRUE}";;
        '?') BudgetAuthPurgeUsageMessage "${0}" && return 1 ;; 
        ':') BudgetAuthPurgeUsageMessage "${0}" && return 1 ;;     
        '#') BudgetAuthPurgeUsageMessage "${0}" && return 1 ;;         
  esac
done


#######################################################################################################################
#### Turn debug on if verbose is on

(( BudgetAuthPurgeDebug == TRUE )) && set -x

#######################################################################################################################
#### Turn syntax on if syntax check option is specified

(( BudgetAuthPurgeSyntax == TRUE ))  && set -n

#######################################################################################################################
#### Script name

GenericJobScriptName="$(basename $0)"

#######################################################################################################################
#### Process ID

GenericJobProcessId="[$$]"

