#!/bin/sh

# Reads a gitsubmodule file and clones the repos
awk -F '=' '

function to_clone_cmd(u,p){
    printf("git clone %s ./%s\n",u,p);
};

/path/{
    gsub(/\s+/,"",$2); path=$2;
};
/url/{
    gsub(/\s+/,"",$2); url=$2;
};

/submodule/{
    seen+=1;
    if(seen > 1){
        to_clone_cmd(url,path);
    }
    url="";
    path="";
};

END{
    to_clone_cmd(url,path);
}' $1 | while read line; do
    sh -xec "eval $line";
done;

