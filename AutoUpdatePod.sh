#!/bin/sh

# ************************* 配合 Fastlane 自动更新私有库 ****************************

echo "\n************************************ 执行自动更新 cocoapod 私有库脚本 ************************************\n"
 
# 获取到的文件路径
file_path=""
file_name=""
# 文件后缀名
file_extension="podspec"
# 文件夹路径，pwd表示当前文件夹
directory="$(pwd)"
 
# 参数1: 路径；参数2: 文件后缀名
function getFileAtDirectory(){
    for element in `ls $1`
    do
        dir_or_file=$1"/"$element
        # echo "$dir_or_file"
        if [ -d $dir_or_file ]
        then
            getFileAtDirectory $dir_or_file
        else
            file_extension=${dir_or_file##*.}
            if [[ $file_extension == $2 ]]; then
#                echo "$dir_or_file 是 $2 文件"
                file_path=$dir_or_file
                file_name=$element
            fi
        fi
    done
}
getFileAtDirectory $directory $file_extension
 
#echo "\n file_path: ${file_path}"
#echo "\n file_name: ${file_name}"
#
#
#echo "\n ---- 读取podspec文件内容 begin ---- \n"
 
# 定义pod文件名称
pod_file_name=${file_name}
# 查找 podspec 的版本
search_str="s.version"
 
# 读取podspec的版本
podspec_version=""
pod_spec_version_new=""
 
#定义了要读取文件的路径
my_file="${pod_file_name}"
while read my_line
do
#输出读到的每一行的结果
# echo $my_line
 
    # 查找到包含的内容，正则表达式获取以 ${search_str} 开头的内容
    result=$(echo ${my_line} | grep "^${search_str}")
    if [[ "$result" != "" ]]
    then
#           echo "\n ${my_line} 包含 ${search_str}"
           # 分割字符串，是变量名称，不是变量的值; 前面的空格表示分割的字符，后面的空格不可省略
        array=(${result// / })
        # 数组长度
        count=${#array[@]}
        # 获取最后一个元素内容
        version=${array[count - 1]}
        # 去掉 '
        version=${version//\'/}
 
        podspec_version=$version
    #else
           # echo "\n ${my_line} 不包含 ${search_str}"
    fi
 
done < $my_file
echo "\n\n\n         【 当前正在更新的库名字是: ${file_name}       版本号：${podspec_version} 】\n\n\n\n\n"

#执行 fastlane 命令 ，并执行更新 私有组件库
if [[ "$file_name" != "" ]];then    #编写代码时，注意[[ A ]] ,A 两边要留空格，不然会报错
    fastlane updatePod tag:$podspec_version specName:$file_name
else
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>> 没有找到 podspec 文件  (⊙︿⊙) <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
fi









