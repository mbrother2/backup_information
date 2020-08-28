#!/bin/bash

_cpanel(){
    # User
    USER_NAME=`ls -1 ${BACKUP_DIR}/cp`
    USER_PASS=`cat ${BACKUP_DIR}/shadow`
    USER_SHELL=`cat ${BACKUP_DIR}/shell`
    
    # Domain
    MAIN_DOMAIN=`cat ${BACKUP_DIR}/userdata/main | grep '^main_domain:' | cut -d' ' -f2`
    
    ADDON_DOMAIN=`cat ${BACKUP_DIR}/userdata/main | sed -n '/addon_domains/,/^[a-zA-Z0-9_]/p' | grep "^\s" | cut -d':' -f1 | awk '{print $1}'`
    CHECK_ADDON=`echo "${ADDON_DOMAIN}" | wc -l`
    if [ ${CHECK_ADDON} -gt 1 ]
    then
        ADDON_DOMAIN="[$(echo "${ADDON_DOMAIN}" | sed 's/^/"/g;s/$/"/g' | sed ':a;N;$!ba;s/\n/, /g')]"
    else
        ADDON_DOMAIN="\"${ADDON_DOMAIN}\""
    fi
    
    ALIAS_DOMAIN=`cat ${BACKUP_DIR}/userdata/main | sed -n '/parked_domains/,/^[a-zA-Z0-9_]/p' | grep "^\s" | awk '{print $2}'`
    CHECK_ALIAS=`echo "${ALIAS_DOMAIN}" | wc -l`
    if [ ${CHECK_ALIAS} -gt 1 ]
    then
        ALIAS_DOMAIN="[$(echo "${ALIAS_DOMAIN}" | sed 's/^/"/g;s/$/"/g' | sed ':a;N;$!ba;s/\n/, /g')]"
    else
        ALIAS_DOMAIN="\"${ALIAS_DOMAIN}\""
    fi
    
    SUB_DOMAIN=`cat ${BACKUP_DIR}/userdata/main | sed -n '/sub_domains/,/^[a-zA-Z0-9_]/p' | grep "^\s" | awk '{print $2}'`
    if [ -z "${SUB_DOMAIN}" ]
    then
        SUB_DOMAIN="\"\""
    else
        SUB_ADDON_DOMAIN=`cat ${BACKUP_DIR}/userdata/main | sed -n '/addon_domains/,/^[a-zA-Z0-9_]/p' | grep "^\s" | awk '{print $2}'`
        REAL_SUBDOMAIN=`echo "${SUB_DOMAIN}" | grep -v "${SUB_ADDON_DOMAIN}"`
        ALL_DOMAIN=$(cat ${BACKUP_DIR}/userdata/main | grep '^main_domain:' | cut -d' ' -f2
            cat ${BACKUP_DIR}/userdata/main | sed -n '/addon_domains/,/^[a-zA-Z0-9_]/p' | grep "^\s" | cut -d':' -f1 | awk '{print $1}'
        )
        SUM_DOMAIN=`echo "${ALL_DOMAIN}" | wc -l`
        SUB_DOMAIN=$(echo {
        i_SUB_DOMAIN=1
        for i in $(echo "${ALL_DOMAIN}")
        do
            SUB_DOMAIN2=`echo "${REAL_SUBDOMAIN}" | grep -c ".$i$"`
            if [ ${SUB_DOMAIN2} -eq 0 ]
            then
                echo -n "            \"$i\": \"\""
            elif [ ${SUB_DOMAIN2} -eq 1 ]
            then
                echo -n "            \"$i\": \"$(echo "${REAL_SUBDOMAIN}" | grep ".$i$" | sed "s/.$i//")\""
            else
                echo -n "            \"$i\": [$(echo "${REAL_SUBDOMAIN}" | grep ".$i$" | sed "s/.$i//" | sed 's/^/"/g;s/$/"/g' | sed ':a;N;$!ba;s/\n/, /g')]"
            fi
            if [ $i_SUB_DOMAIN -lt ${SUM_DOMAIN} ]
            then
                echo ","
            else
                echo ""
            fi
            i_SUB_DOMAIN=$((i_SUB_DOMAIN+1))
        done
        echo "        }"       
        )
    fi

    # Database
    ALL_DATABASE=`ls -1 ${BACKUP_DIR}/mysql | grep ".create$" | cut -d'.' -f1`
    CHECK_DATABASE=`echo "${ALL_DATABASE}" | wc -l`
    if [ ${CHECK_DATABASE} -gt 1 ]
    then
        ALL_DATABASE2="[$(echo "${ALL_DATABASE}" | sed 's/^/"/g;s/$/"/g' | sed ':a;N;$!ba;s/\n/, /g')]"
    else
        ALL_DATABASE2="\"${ALL_DATABASE}\""
    fi
    
    if [ -z "${ALL_DATABASE}" ]
    then
        PRIVILEGES="\"\""
    else
        PRIVILEGES=$(echo "{"
            i_DATABASE=1
            for i in $(echo "${ALL_DATABASE}")
            do
                DATABASE_USER=`cat ${BACKUP_DIR}/mysql.sql | grep -v "'${USER_NAME}'" | grep "$(echo $i | sed 's/_/\\\\\\\\\\_/g').* TO" | cut -d"'" -f2 | sort | uniq`
                if [ -z "${DATABASE_USER}" ]
                then
                    echo -n "            \"$i\": \"\""
                else
                    echo "            \"$i\": {"
                    CHECK_DATABASE_USER=`echo "${DATABASE_USER}" | wc -l`
                    i_DATABASE2=1
                    for j in $(echo "${DATABASE_USER}")
                    do
                        PRIVILEGES2=`cat ${BACKUP_DIR}/mysql.sql | grep "$(echo $i | sed 's/_/\\\\\\\\\\_/g').* TO '$j'" | sed 's/GRANT //;s/ ON.*//' | uniq`
                        echo -n "                \"$j\": \"${PRIVILEGES2}\""
                        if [ $i_DATABASE2 -lt ${CHECK_DATABASE_USER} ]
                        then
                            echo ","
                        else
                            echo ""
                        fi
                        i_DATABASE2=$((i_DATABASE2+1))
                    done
                    echo -n "            }"
                fi
                if [ $i_DATABASE -lt ${CHECK_DATABASE} ]
                then
                    echo ","
                else
                    echo ""
                fi
                i_DATABASE=$((i_DATABASE+1))
            done
            echo "        }"
        )
    fi
}

_directadmin(){
    # User
    USER_NAME=`cat ${BACKUP_DIR}/backup/user.conf | grep "^username=" | cut -d'=' -f2`
    USER_PASS=`cat ${BACKUP_DIR}/backup/.shadow`
    USER_SHELL=`cat ${BACKUP_DIR}/backup/user.conf | grep "^ssh=" | cut -d'=' -f2`
    if [ "${USER_SHELL}" == "ON" ]
    then
        USER_SHELL="/bin/bash"
    else
        USER_SHELL="/bin/false"
    fi
    
    # Domain
    MAIN_DOMAIN=`cat ${BACKUP_DIR}/backup/user.conf | grep "^domain=" | cut -d'=' -f2`
    
    ADDON_DOMAIN=`ls -1 ${BACKUP_DIR}/domains | grep -v "${MAIN_DOMAIN}"`
    CHECK_ADDON=`echo "${ADDON_DOMAIN}" | wc -l`
    if [ ${CHECK_ADDON} -gt 1 ]
    then
        ADDON_DOMAIN="[$(echo "${ADDON_DOMAIN}" | sed 's/^/"/g;s/$/"/g' | sed ':a;N;$!ba;s/\n/, /g')]"
    else
        ADDON_DOMAIN="\"${ADDON_DOMAIN}\""
    fi
    
    ALIAS_DOMAIN=`find ${BACKUP_DIR}/backup -iname "domain.pointers"`
    if [ -z "${ALIAS_DOMAIN}" ]
    then
        ALIAS_DOMAIN="\"\""
    else
        SUM_ALIAS=`echo "${ALIAS_DOMAIN}" | wc -l`
        ALIAS_DOMAIN=$(echo {
        i_ALIAS_DOMAIN=1
        for i in $(echo "${ALIAS_DOMAIN}")
        do
            DOMAIN=`echo "$i" | rev | cut -d'/' -f 2 | rev`
            ALIAS_DOMAIN2=`cat $i | cut -d'=' -f1`
            CHECK_ALIAS=`echo "${ALIAS_DOMAIN2}" | wc -l`
            if [ ${CHECK_ALIAS} -eq 1 ]
            then
                echo -n "            \"${DOMAIN}\": \"${ALIAS_DOMAIN2}\""
            else
                echo -n "            \"${DOMAIN}\": \"[$(echo "${ALIAS_DOMAIN2}" | sed ':a;N;$!ba;s/\n/, /g')]\""
            fi
            if [ $i_ALIAS_DOMAIN -lt ${SUM_ALIAS} ]
            then
                echo ","
            else
                echo ""
            fi
            i_ALIAS_DOMAIN=$((i_ALIAS_DOMAIN+1))
        done
        echo "        }"
        )
    fi
    
    SUB_DOMAIN=`cat ${BACKUP_DIR}/backup/*/subdomain.list`
    if [ -z "${SUB_DOMAIN}" ]
    then
        SUB_DOMAIN="\"\""
    else
        SUM_DOMAIN=`ls -1 ${BACKUP_DIR}/domains | wc -l`
        SUB_DOMAIN=$(echo {
        i_SUB_DOMAIN=1
        for i in $(ls -1 ${BACKUP_DIR}/domains)
        do
            SUB_DOMAIN2=`cat ${BACKUP_DIR}/backup/$i/subdomain.list`
            CHECK_SUB=`echo "${SUB_DOMAIN2}" | wc -l`
            if [ ${CHECK_SUB} -eq 1 ]
            then
                echo -n "            \"$i\": \"${SUB_DOMAIN2}\""
            else
                echo -n "            \"$i\": \"[$(echo "${SUB_DOMAIN2}" | sed ':a;N;$!ba;s/\n/, /g')]\""
            fi
            if [ $i_SUB_DOMAIN -lt ${SUM_DOMAIN} ]
            then
                echo ","
            else
                echo ""
            fi
            i_SUB_DOMAIN=$((i_SUB_DOMAIN+1))
        done
        echo "        }"       
        )
    fi
    
    # Database
    ALL_DATABASE=`ls -1 ${BACKUP_DIR}/backup | grep "_.*.conf$" | cut -d'.' -f1`
    CHECK_DATABASE=`echo "${ALL_DATABASE}" | wc -l`
    if [ ${CHECK_DATABASE} -gt 1 ]
    then
        ALL_DATABASE2="[$(echo "${ALL_DATABASE}" | sed 's/^/"/g;s/$/"/g' | sed ':a;N;$!ba;s/\n/, /g')]"
    else
        ALL_DATABASE2="\"${ALL_DATABASE}\""
    fi
    
    if [ -z "${ALL_DATABASE}" ]
    then
        PRIVILEGES="\"\""
    else
        PRIVILEGES=$(echo {
            i_DATABASE=1
            for i in $(echo "${ALL_DATABASE}")
            do
                DATABASE_USER=`cat ${BACKUP_DIR}/backup/$i.conf | grep '=alter_priv=' | grep -v "^${USER_NAME}=" | cut -d'=' -f1`
                CHECK_DATABASE_USER=`echo "${DATABASE_USER}" | wc -l`
                i_DATABASE2=1
                echo "            \"$i\": {"
                for j in $(echo "${DATABASE_USER}")
                do
                    PRIVILEGES2=`cat ${BACKUP_DIR}/backup/$i.conf | grep "^$j=" | sed "s/^$j=//; s/&/\n/g" | grep -v "^passwd=" | grep "=Y$" | cut -d'=' -f1 | sed 's/_/ /g; s/ priv$//g' | sed ':a;N;$!ba;s/\n/, /g'`
                    PRIVILEGES2=${PRIVILEGES2^^}
                    echo -n "                \"$j\": \"${PRIVILEGES2}\""
                    if [ $i_DATABASE2 -lt ${CHECK_DATABASE_USER} ]
                    then
                        echo ","
                    else
                        echo ""
                    fi
                    i_DATABASE2=$((i_DATABASE2+1))
                done
                echo -n "            }"
                if [ $i_DATABASE -lt ${CHECK_DATABASE} ]
                then
                    echo ","
                else
                    echo ""
                fi
                i_DATABASE=$((i_DATABASE+1))
            done
            echo "        }"
        )
    fi
}

RANDOM_STRING=`date +%s | sha256sum | base64 | head -c 12`
BACKUP_DIR=`realpath $1`
if [ -d "${BACKUP_DIR}" ]
then
    BACKUP_DIR=${BACKUP_DIR}
else
    PARENT_DIR=`echo "${BACKUP_DIR}" | rev | cut -d/ -f2- | rev`
    cd ${PARENT_DIR}
    mkdir tmp_${RANDOM_STRING}
    CHECK_BACKUP=`tar -tf "${BACKUP_DIR}" --exclude='*/*' | wc -l`
    if [ ${CHECK_BACKUP} -eq 1 ]
    then
        DIR_NAME=`tar -tf "${BACKUP_DIR}" --exclude='*/*' | sed 's/\///'`
        tar -xf ${BACKUP_DIR} -C ${PARENT_DIR}/tmp_${RANDOM_STRING} --exclude="${DIR_NAME}/homedir" --exclude="${DIR_NAME}/mysql/*.sql"
        BACKUP_DIR="${PARENT_DIR}/tmp_${RANDOM_STRING}/${DIR_NAME}"
    elif [ ${CHECK_BACKUP} -eq 2 ]
    then
        tar -xf ${BACKUP_DIR} -C ${PARENT_DIR}/tmp_${RANDOM_STRING} --exclude="backup/home.tar.gz" --exclude="backup/*.sql"
        BACKUP_DIR="${PARENT_DIR}/tmp_${RANDOM_STRING}"
    fi
fi

if [ -f "${BACKUP_DIR}/backup/user.conf" ]
then
    _directadmin
elif [ -f "${BACKUP_DIR}/userdata/main" ]
then
    _cpanel
else
    echo "Can not show information, exit!"
    rm -rf tmp_${RANDOM_STRING}
    exit 1
fi
rm -rf tmp_${RANDOM_STRING}

# Show information
cat << EOF
{
    "user": {
        "name": "${USER_NAME}",
        "password": "${USER_PASS}",
        "shell": "${USER_SHELL}"
    },
    "domain": {
        "main": "${MAIN_DOMAIN}",
        "addon": ${ADDON_DOMAIN},
        "alias": ${ALIAS_DOMAIN},
        "sub": ${SUB_DOMAIN}
    },
    "database": {
        "all": ${ALL_DATABASE2},
        "privilege": ${PRIVILEGES}
    }
}
EOF
exit 0