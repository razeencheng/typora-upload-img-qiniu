#!/bin/bash

set -e
IFS=$';'

BUCKET="blog"  # 这里换成 你在七牛的空间名称
QSHELL="D:\Users\Razeen\wspace\bin\qshell.exe" # 这里换成 你qshell可执行文件的路径
DOMAIN="https://st.razeen.cn" # 这里换成 你在七牛对应的自定义域名
PATH_PREFIX="img" # 这里换成 你想设置的图片路径前缀
ACCESSKEY=xxxxxxxx # 这里设置 你的七牛密钥
SECUREKEY=xxxxxxx 
ACTNAME=self # 可以给这个账号一个别名

$QSHELL account $ACCESSKEY $SECUREKEY $ACTNAME -w

i=0

for filepath in $@; do

    i=$((${i}+1))

    filename="$(date +'%Y%m%d%H%M%S')_${filepath##*/}"                                                                         

    if [ -f "${filepath}" ]; then

         ${QSHELL} rput ${BUCKET} "${PATH_PREFIX}/${filename}" "${filepath}" > /dev/null

        if [ $? -eq 0 ]; then

            if [ ${i} -eq 1 ]; then 
                echo "Upload Success:"
            fi

            echo "${DOMAIN}/${PATH_PREFIX}/${filename}"

        else
            echo "upload ${filepath} failed!"
            exit 1;
        fi
    else 
        echo "${filepath} does not exist"
        exit 1;
    fi

done
