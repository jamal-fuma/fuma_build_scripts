#!/bin/sh

# (c) FumaSoftware 2012
#
# Resource compilation for C/C++
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#
array_name()
{
        local path="$1";
        local dirname=`dirname "$1"`;
        local filename="$(basename "$dirname")_$(basename "$1")";

        local arr_name=`echo $filename | tr '.' '_' |  sed -e 's/[-\.]\+/_/g;' | sed -e 's/__\+/_/g' `;
        printf "bytes_%s" "$arr_name" | sed -e 's/-/_/g'
}

hexdump_format_string()
{
        local bytes_per_col=$1;
        local columns_per_row=$2;
        printf '  "\t" %s/%s "0x%%0%sx, " "\n"' "$columns_per_row" "$bytes_per_col" "$(($bytes_per_col*2))"
}

sed_format_string()
{
        printf 's/[,]*[ ]*0x[ ]*,//g';
}

generate_array()
{
        local filename="$1";
        local arr_name="$(array_name $1)";
        printf 'template<typename T>\nvoid copy_%s_str(T & out)\n{\n' "$arr_name";
        printf '/* array generated from hexdump of %s */\nconst unsigned char %s[]=\n{\n' "$1" "$arr_name" ;
        hexdump -v -e "$(hexdump_format_string 1 16)" $filename | sed -e "$(sed_format_string $1)"
        printf '};\nconst unsigned char * data_start_%s = &%s[0];\n' "$arr_name" "$arr_name" ;
        printf 'const unsigned char * data_end_%s   = (data_start_%s
        + sizeof(%s));\n' "$arr_name" "$arr_name" "$arr_name" ;
        printf 'std::copy(data_start_%s,data_end_%s,out);\n}\n' "$arr_name" "$arr_name" ;
}

generate_array_from_dynamic_read()
{
        local filename="$1";
        local basename=`echo $1 | sed -e 's/^\(.*\)assets//'`;
        local arr_name="$(array_name $1)";
        printf 'template<typename T>\nvoid copy_%s_str(T & out)\n{\n' "$arr_name";
        printf '        Util::Configuration().asset_stream("%s",out);\n' "${basename}";
        printf '}\n'
}

# print make rules
if [ "$1" = "-n" ] && [ -f ${2} ] ; then
    printf "%s generates: %s\n" "$2" `array_name $2`;
fi

if [ -f ${1} ] ; then
    generate_array "$1"
fi

if [ "$1" = "--static" ] && [ -f ${2} ] ; then
    generate_array "$2"
fi

if [ "$1" = "--dynamic" ] && [ -f ${2} ] ; then
    generate_array_from_dynamic_read "$2"
fi
