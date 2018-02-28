#!/bin/bash bash

swaggerName='Swagger.yaml'

apib2swagger -i apiary.apib --yaml -o ${swaggerName}

replacer() {
	sed -i "s|${1}|${2}|g" ${swaggerName} ;
}

clear211() {
    line=`grep -n "'211'" ${swaggerName} | grep -o "^[0-9]*"`
	iterr=0;
	for fn in $line;
	    do
	    fromline=$(($fn+2-$iterr*4));
	    toline=$(($fromline+3));
	    sed -i "$fromline,$toline d" ${swaggerName};
	    iterr=$(($iterr+1));

	done
}

deleteBasePath() {
    sed -i '/^basePath/d' ${swaggerName}
}

changePagesArray(){
    number=`grep -n "pages%5b%5d" ${swaggerName} | grep -o "^[0-9]*"`
    line=$(($number+4));
    sed -i "${line}s|type: array|type: integer|" ${swaggerName}
    sed -i "s|pages%5b%5d|pages|g" ${swaggerName} ;
}

pasteAuthorisation(){
    line=`grep -n "parameters:" ${swaggerName} | grep -o "^[0-9]*"`
	iterr=0;
	for fn in $line;
	    do
	    prevline=`sed -n $(($fn-1))p ${swaggerName} | tr -d ' '`
	    if [ ! $prevline = "-Authentication" ]; then
	    fromline=$(($fn+1+$iterr*6));
	    ex -sc "${fromline}i|        - name: Authorization
          in: header
          description: Bearer Access Token obtained from client credentials
          required: true
          type: string
          default: Bearer AccessToken" -cx ${swaggerName}
	    iterr=$(($iterr+1));
        fi
	done
}

removeEmptyParams(){
    sed -i "s|[][]||g" ${swaggerName} ;
}

grantTypeSetType(){
    line=`grep -n "description: Authentication grant type" ${swaggerName} | grep -o "^[0-9]*"`;
    iterr=0;
	for fn in $line;
	    do
	    fiveLine=`sed -n $((fn+$iterr*2+5))p ${swaggerName} | tr -d ' '`
	    nextLine=$((fn+1))
	    if [ $fiveLine = "username:" ]; then
        ex -sc "${nextLine}i|                enum:
                  - password" -cx ${swaggerName}
        iterr=$(($iterr+1))
	    else
	    movedLine=$(($fn+$iterr*2+1));
	    ex -sc "${movedLine}i|                enum:
                  - refresh_token" -cx ${swaggerName}
	    fi
	done
}
replacer 'number' 'integer' && clear211 ${swaggerName} && deleteBasePath ${swaggerName} && pasteAuthorisation ${swaggerName} && changePagesArray ${swaggerName} && removeEmptyParams ${swaggerName} && grantTypeSetType ${swaggerName}
