#!/usr/bin/env bash

__ScriptVersion="0.0.1"

#===  FUNCTION  ================================================================
#         NAME:  curlxmlrpc
#  DESCRIPTION:  Query a xmlrpc server
#===============================================================================
function usage ()
{
    echo "Usage :  $0 host method [sibf]

    Options:
    -h|help       Display this message
    -v|version    Display script version
    -s|           A string parameter
    -b|           A bool parameter (0,1)
    -i|           A int parameter 
    -f|           A float parameter 
    "

}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
ALL_PARAMS=()

# PARSE POSITIONAL PARAMETERS
if [ -z "$1" ]; then
    echo "No host:port supplied"
    usage
    exit
else
    HOST=$1
    #HOST=${@:$OPTIND:1}
fi

if [ -z "$2" ]; then
    echo "No method name supplied"
    usage
    exit

else
    METHOD_CALL=$2
    #METHOD_CALL=${@:$OPTIND+1:1}
fi

shift 2

# PARSE OPTIONS
while getopts ":hvs:i:f:b:" opt
do
  case $opt in

    h|help     )  usage; exit 0   ;;

    v|version  )  echo "$0 -- Version $__ScriptVersion"; exit 0   ;;

    s|string  )  
        ALL_PARAMS+=("<param><value><string>$OPTARG</string></value></param>")
        ;;
    i|int  )  
        ALL_PARAMS+=("<param><value><int>$OPTARG</int></value></param>")
        ;;
    f|float  )  
        ALL_PARAMS+=("<param><value><double>$OPTARG</double></value></param>")
        ;;
    b|bool  )  
        ALL_PARAMS+=("<param><value><boolean>$OPTARG</boolean></value></param>")
        ;;
    \?)
        echo "Invalid option -$OPTARG"
        usage
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument"
        exit 1
        ;;

    * )  echo -e "\n  Option does not exist : $OPTARG\n"
          usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))


#if [ $(( $# - $OPTIND )) -lt 1 ]; then
    ##echo "Usage: `basename`"
    #usage
    #exit 1
#fi


#for val in "${ALL_PARAMS[@]}"; do
    #echo " - $val"
#done

# Generalizing to differnt OS

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform        
	curl -s -H 'Content-Type: text/xml' -d "<methodCall><methodName>$METHOD_CALL</methodName><params>$ALL_PARAMS</params></methodCall>" $HOST | \
	xpath '//value//string|//value/base64|//value/double' | sed 's/<[^>]*>//g'
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
	curl -s -H 'Content-Type: text/xml' -d "<methodCall><methodName>$METHOD_CALL</methodName><params>$ALL_PARAMS</params></methodCall>" $HOST | \
	xmllint --format --xpath "//value//string/text()" - | sed 's/<[^>]*>//g'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under Windows NT platform
	curl -s -H 'Content-Type: text/xml' -d "<methodCall><methodName>$METHOD_CALL</methodName><params>$ALL_PARAMS</params></methodCall>" $HOST | \
	xpath '//value//string|//value/base64|//value/double' | sed 's/<[^>]*>//g'
fi

