#!/bin/bash

VENDOR_LIST='general_electric
mitsubishi
Red_Lion_Controls
Niagara
Other
'

PORT_LIST='502-Modbus
102-Siemens_S7
1911,4911-Fox
47808-BACnet
18245,18246-GE-SRTP
5006,5007-Mitsubishi
789-Red_Lion_Controls_Crimson
Other
'

COUNTRY_LIST='ru
kz
us
uk
ge
Other
'

ADDITION_LIST='hart-ip
PLC
Other
'
function column_menu()
{
    clear
    echo "$COLUMN_MENU_TITLE"
    COLUMN_MENU_COUNTER=0
    COLUMN_MENU_NUMLIST=""
    for i in $COLUMN_MENU_LIST; do
        echo $(( COLUMN_MENU_COUNTER++ )) &> /dev/null
        COLUMN_MENU_NUMLIST="$COLUMN_MENU_NUMLIST*${COLUMN_MENU_COUNTER})${i}"
        if (( $COLUMN_MENU_COUNTER % 4 == 0 )); then
            COLUMN_MENU_NUMLIST="$COLUMN_MENU_NUMLIST"$'\n'
        fi
    done

    column -s '*' -t < <(echo "$COLUMN_MENU_NUMLIST") 

    echo -n "Your choice >>> " 
    read column_menu_choose
    echo -n "" 
    COLUMN_MENU_CHOOSE=$(echo "$COLUMN_MENU_LIST" | head -$column_menu_choose | tail -n 1 )
    clear	
}

function get_filter {
	COLUMN_MENU_LIST=$VENDOR_LIST
	COLUMN_MENU_TITLE="Choose vendor:"
	column_menu
	if [[ $COLUMN_MENU_CHOOSE = "Other" ]]; then
		echo -n "Enter vendor >>> "; read INPUT
		VENDOR=$([[ $INPUT = "" ]] && echo "" || echo "product:'$INPUT'")
	else
		VENDOR="product:$COLUMN_MENU_CHOOSE"
	fi
	COLUMN_MENU_LIST=$PORT_LIST
	COLUMN_MENU_TITLE="Choose port:"
	column_menu
	if [[ $COLUMN_MENU_CHOOSE = "Other" ]]; then
		echo -n "Enter port >>> "; read INPUT
		PORT=$([[ $INPUT = "" ]] && echo "" || echo "port:$INPUT")
	else
		PORT="port:$(echo $COLUMN_MENU_CHOOSE | cut -d '-' -f1)"
	fi
	COLUMN_MENU_LIST=$COUNTRY_LIST
	COLUMN_MENU_TITLE="Choose country:"
	column_menu
	if [[ $COLUMN_MENU_CHOOSE = "Other" ]]; then
		echo -n "Enter country >>> "; read INPUT
		COUNTRY=$([[ $INPUT = "" ]] && echo "" || echo "country:$INPUT")
	else
		COUNTRY="country:$COLUMN_MENU_CHOOSE"
	fi
	COLUMN_MENU_LIST=$ADDITION_LIST
	COLUMN_MENU_TITLE="Choose Addition:"
	column_menu
	if [[ $COLUMN_MENU_CHOOSE = "Other" ]]; then
		echo -n "Enter addition >>> "; read INPUT
		ADDITION=$INPUT
	else
		ADDITION=$COLUMN_MENU_CHOOSE
	fi
	FILTER="$ADDITION $VENDOR $PORT $COUNTRY"
	echo $FILTER
}



if [ -z $SHODAN_API_KEY ]; then
	echo "No api key provided" 1>&2
	echo "Please defile SHODAN_API_KEY env variable" 1>&2
	exit 1
fi

URL="https://api.shodan.io/shodan/host/search"

get_filter

QUERY="$URL?key=$SHODAN_API_KEY&$FILTER"
COMMAND="curl '$QUERY'"
eval "$COMMAND"
