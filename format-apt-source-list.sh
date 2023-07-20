#!/bin/bash

function format_source() {
    local authority_format="%s:%s@software.open-xchange.com"
    local dovecot_ver="2.3.20"
    local path_format="/products/dovecot/%s/%s/%s"
    local scheme="https"
    local source_format="deb %s ./" # contains spaces; quote!
    local ubuntu_ver="Ubuntu_20.04"
    local url_format="%s://%s%s"

    local username=$1
    local password=$2
    local variable=$3

    local authority=$(printf $authority_format $username $password)
    local path=$(printf $path_format $dovecot_ver $variable $ubuntu_ver)
    local url=$(printf $url_format $scheme $authority $path)

    printf "$source_format" $url
}

function main() {
    local components=( \
        "base" \
        "3rdparty/cassandra-cpp-driver" \
        "devtools/fsserver" \
        "fts" \
        "obox2" \
        "plugin/imap-proxyauth-plugin" \
        "plugin/pigeonhole-sieve-zimbra-compat-plugin" \
        "plugin/vault-plugin" \
    )

    local username=$1
    local password=$2

    local component

    for component in "${components[@]}"
    do
        echo "$(format_source $username $password $component)"
    done
}

main $@
