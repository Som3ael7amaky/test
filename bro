#!/bin/bash

_get_zlink () {

    local regex

    regex='(https?)://github.com/.+/.+'

    if [[ $UPSTREAM_REPO == "zel" ]]

    then

        echo "aHR0cHM6Ly9naXRodWIuY29tL1plaW5uMS9aRUxaQUwvYXJjaGl2ZS9tYXN0ZXIuemlw" | base64 -d

    elif [[ $UPSTREAM_REPO =~ $regex ]]

    then

        if [[ $UPSTREAM_REPO_BRANCH ]]

        then

            echo "${UPSTREAM_REPO}/archive/${UPSTREAM_REPO_BRANCH}.zip"

        else

            echo "${UPSTREAM_REPO}/archive/master.zip"

        fi

    else

        echo "aHR0cHM6Ly9naXRodWIuY29tL1plaW5uMS9aRUxaQUwvYXJjaGl2ZS9tYXN0ZXIuemlw" | base64 -d

    fi

}

_get_repolink () {

    local regex

    local rlink

    regex='(https?)://github.com/.+/.+'

    if [[ $UPSTREAM_REPO == "zel" ]]

    then

        rlink=`echo "aHR0cHM6Ly9naXRodWIuY29tL1plaW5uMS9aRUxaQUw=" | base64 -d`

    elif [[ $UPSTREAM_REPO =~ $regex ]]

    then

        rlink=`echo "${UPSTREAM_REPO}"`

    else

        rlink=`echo "aHR0cHM6Ly9naXRodWIuY29tL1plaW5uMS9aRUxaQUw=" | base64 -d`

    fi

    echo "$rlink"

}

_run_python_code() {

    python3${pVer%.*} -c "$1"

}

_run_catpackgit() {

    $(_run_python_code 'from git import Repo

import sys

OFFICIAL_UPSTREAM_REPO = "https://github.com/som3ael7amaky/test"

ACTIVE_BRANCH_NAME = "master"

repo = Repo.init()

origin = repo.create_remote("temponame", OFFICIAL_UPSTREAM_REPO)

origin.fetch()

repo.create_head(ACTIVE_BRANCH_NAME, origin.refs[ACTIVE_BRANCH_NAME])

repo.heads[ACTIVE_BRANCH_NAME].checkout(True) ')

}

_run_catgit() {

    local repolink=$(_get_repolink)

    $(_run_python_code 'from git import Repo

import sys

OFFICIAL_UPSTREAM_REPO="'$repolink'"

ACTIVE_BRANCH_NAME = "'$UPSTREAM_REPO_BRANCH'" or "main"

repo = Repo.init()

origin = repo.create_remote("temponame", OFFICIAL_UPSTREAM_REPO)

origin.fetch()

repo.create_head(ACTIVE_BRANCH_NAME, origin.refs[ACTIVE_BRANCH_NAME])

repo.heads[ACTIVE_BRANCH_NAME].checkout(True) ')

}

_start_bot () {

    local zippath

    zippath="ZedThon1.zip"

    echo "⌭ جاري تنزيل اكواد السورس ⌭"

    wget -q $(_get_zlink) -O "$zippath"

    echo "⌭ تفريغ البيانات ⌭"

    CATPATH=$(zipinfo -1 "$zippath" | grep -v "/.");

    unzip -qq "$zippath"

    echo "⌭ تـم التفريـغ ⌭"

    echo "⌭ يتم التنظيف ⌭"

    rm -rf "$zippath"

    _run_catpackgit

    cd $CATPATH

    _run_catgit

    python3 ../setup/updater.py ../requirements.txt requirements.txt

    chmod -R 755 bin

    echo "⌭ جـاري بـدء تنصيـب ايـگس ⌭ "

    echo "

    "

    python3 -m zthon

}

_start_bot
