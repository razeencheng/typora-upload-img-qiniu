#  [Typora 自动上传图片到七牛云](https://razeencheng.com/post/typora-upload-image-qiniu.html)



用 Markdown 写博客配图片一直是个烦恼我的为问题， 每次上传图片都比较麻烦，或是中断思路，或是最后集中处理耗费时间。今天无意中，发现了 Typora 的图片自动上传功能，配合一段脚本，将插入的图片自动上传七牛，让写文章更爽了。



<!--more-->

### 偏好设置



我们看到在 Typora 的偏好设置中，有将图片插入时执行的动作。 在上传的设置中可以选择几种上传方式，由于前面几种要下其他软件，我就直接选了其他命令的方式。

![image-20210130225707678](https://st.razeen.cn/img/20210130225707_image-20210130225707678.png)



### 规则



看了一下规则，很简单。 当你插入图片的时候会执行你的命令。 假如你的命令叫 `upload-image.sh` , 则会执行：

```bash
upload-image.sh "imagepath1" "imagepath2" ... 
```

而你的命令只需要如下格式返回上传后的链接：

``` bash
Upload Success:
http://remote-image-1.png
http://remote-image-2.png
```



### qshell

知道了脚本怎么写，我首先想到了，平常用来上传文件到七牛的命令行工具 `qshell` 。

 [GitHub🔗](https://github.com/qiniu/qshell)上有详细的说明，你可以下下来自己编译，也可以直接下载编译好的。



关于命令使用，上面也有详细的介绍。 其实，我们这里主要只用到两个命令。



- 设置账户。

  ``` bash
  qshell account [AccessKey] [SecretKey] [Name]
  ```

  其中，两个 Key 七牛账户中可以添加。 后面的 Name 随便写。

- 上传

  ``` bash
  qshell rput <Bucket> <Key> <LocalFile>
  ```

  其中，Bucket 就是对象存储空间的名字， key 上传后的路径， LocalFile 本地文件路径。



### 写脚本



最新的脚本可以看[这里](https://github.com/razeencheng/typora-upload-img-qiniu)。



``` bash
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

sys=$(uname -s)

i=0

for filepath in $@; do

    i=$((${i}+1))

    date_prefix=$(date +'%Y%m%d%H%M%S')

    filename="${date_prefix}-${filepath##*/}" 

    # windows 路径匹配不一样
    if [[ ${sys} == "MINGW64"* ]]; then
        filename="${date_prefix}-${filepath##*\\}"
    fi                                                                   

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
```



### 设置



1. 保存上面脚本，修改当中需要的信息，并添加执行权限。

2. 在 `Typora` 中设置 这个命令（绝对路径），如

   ![image-20210131000315109](https://st.razeen.cn/img/20210131000315_image-20210131000315109.png)

   Mac/Ubutun上这么设置没问题， 但Windows上可能会出现如下错误。

   ![image-20210701002428848](https://st.razeen.cn/img/20210701002430_image-20210701002428848.png)

   这时我们需要换一个脚本解释器，如换成 `Git Bash`，如下图，直接在脚本前面加上`Git Bash`路径。

   ![image-20210701002924703](https://st.razeen.cn/img/20210701002926-image-20210701002924703.png)

   

4. 最后使用效果如下：

   ![image-20210131000625463](https://st.razeen.cn/img/20210131000625_image-20210131000625463.png)



### 相关知识点

- shell 脚本读取用户输入参数：

  ``` 
  $# 是传给脚本的参数个数
  $0 是脚本本身的名字
  $1是传递给该shell脚本的第一个参数
  $2是传递给该shell脚本的第二个参数
  $@ 是传给脚本的所有参数的列表
  ```

- shell脚本中判断上一个命令是否执行成功

  ```
  shell中使用符号 $? 来显示上一条命令执行的返回值，如果为0则代表执行成功，其他表示失败。
  ```

- shell 从路径中提取文件名和目录名

  ``` 
  提取文件名 ${filepath##*/}
  提取文件后缀 ${filepath##*.} 或 ${filepath#*.}
  提取目录 ${filepath%/*}
  主要原理：
  #：表示从左边算起第一个
  %：表示从右边算起第一个
  ##：表示从左边算起最后一个
  %%：表示从右边算起最后一个
  
  除此之外，basename 和 filename 命令也可以做到。
  ```
