#
# completion definition for gmtool
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Some versions of bash, for example Bash 3.2 on Mac OS X, do not have compopt
_gmtool_has_compopt() {
    [ "$(type -t compopt)" = "builtin" ]
}

_gmtool_compopt() {
    if _gmtool_has_compopt ; then
        compopt $*
    fi
}

_gmtool_word_is_in() {
    # args: <word> <option1> <option2> <option3>...
    # Returns 0 if word is one of the options
    local key
    local options
    key=$1
    shift
    options="$*"
    for option in $options ; do
        if [ "$key" = "$option" ] ; then
            return 0
        fi
    done
    return 1
}

_gmtool_sysprop_complete() {
    local SYSPROPS="PRODUCT MODEL RELEASE MANUFACTURER BRAND BOARD DISPLAY \
          DEVICE SERIAL TYPE FINGERPRINT TAGS"
    _gmtool_compopt -o nospace
    COMPREPLY=( $(compgen -W "$SYSPROPS" -S: -- "$1") )
}

_gmtool() {
    local cur prev where timeout
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    OPTIONS="--timeout -t --verbose -v --cloud"
    COMMANDS="admin config device help license version"

    where=OPT
    for ((i=1; i <= COMP_CWORD; i++)); do
        cur="${COMP_WORDS[i]}"
        case "${cur}" in
        -t)
            where=OPT_TIMEOUT
            ;;
        -*)
            where=OPT
            ;;
        *)
            if [[ $where == OPT_TIMEOUT ]]; then
                where=OPT_TIMEOUT_ARG
            elif [[ $where == OPT_TIMEOUT_ARG ]]; then
                where=OPT
            else
                where=COMMAND
                break
            fi
            ;;
        esac
    done

    # Complete option and commands on first completion and not just commands
    if [[ $where == COMMAND && $i -ge $COMP_CWORD ]]; then
        where=OPT
    fi

    case $where in
    OPT)
        COMPREPLY=($(compgen -W "${OPTIONS} ${COMMANDS}" -- "$cur"))
        ;;
    OPT_TIMEOUT_ARG)
        ;;
    COMMAND)
        if [[ $i -eq $COMP_CWORD ]]; then
            COMPREPLY=( $(compgen -W "$COMMANDS" -- "$cur") )
        else
            i=$((i+1))
            case "${cur}" in
            license)
                _gmtool_license_ $i
                ;;
            config)
                _gmtool_config_ $i
                ;;
            admin)
                _gmtool_admin_ $i
                ;;
            device)
                _gmtool_device_ $i
                ;;
            *)
                COMPREPLY=( $(compgen -W "$COMMAND" -- "$cur") )
                ;;
            esac
        fi
        ;;
    esac

    return 0
}

_gmtool_license_() {
    local i where cur prev
    COMMANDS="count info register validity"
    i=$1
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    where=UNKNOW
    case "${prev}" in
    license)
        where=MAIN_COMMANDS
        ;;
    *)
        ;;
    esac

    cur="${COMP_WORDS[COMP_CWORD]}"
    case $where in
    MAIN_COMMANDS)
        COMPREPLY=($(compgen -W "${COMMANDS}" -- "$cur"))
        return
        ;;
    *)
        return
        ;;
    esac
    return
}

_gmtool_config_() {
    local where cur prev
    SUBCOMMANDS="clearcache print reset signout"
    UNAMED_OPTIONS="username password proxy_address proxy_port proxy_username proxy_password license_server_address"
    ONOFF_OPTIONS="store_credentials statistics use_custom_sdk proxy proxy_auth license_server"
    FILE_OPTIONS="virtual_device_path sdk_path screen_capture_path"

    prev="${COMP_WORDS[COMP_CWORD-1]}"
    if [ "$prev" = "config" ] ; then
        where=MAIN_COMMANDS
    elif _gmtool_word_is_in "$prev" "$ONOFF_OPTIONS" ; then
        where=ONOFF_OPTION
    elif _gmtool_word_is_in "$prev" "$UNAMED_OPTIONS" ; then
        where=OPTION
    elif _gmtool_word_is_in "$prev" "$FILE_OPTIONS" ; then
        where=FILE
    elif _gmtool_word_is_in "$prev" "$SUBCOMMANDS" ; then
        where=COMMANDS
    else
        where=OPT_PARAM
    fi

    cur="${COMP_WORDS[COMP_CWORD]}"
    case "$where" in
    ONOFF_OPTION)
        COMPREPLY=( $(compgen -W "on off" -- "$cur") )
        return
        ;;
    FILE)
        _adb_util_complete_local_file "$cur"
        return
        ;;
    MAIN_COMMANDS)
        COMPREPLY=( $(compgen -W "$SUBCOMMANDS $UNAMED_OPTIONS $ONOFF_OPTIONS $FILE_OPTIONS " -- "$cur") )
        return
        ;;
    OPT_PARAM)
        COMPREPLY=( $(compgen -W "$UNAMED_OPTIONS $ONOFF_OPTIONS $FILE_OPTIONS " -- "$cur") )
        return
        ;;
    esac
}

_gmtool_admin_create_edit_startdisposable_() {
    local i where cur prev
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cur="${COMP_WORDS[COMP_CWORD]}"
    i=$(($1-1))
    for ((; i <= COMP_CWORD; i++)); do
        cur="${COMP_WORDS[i]}"
        case "${cur}" in
        create|startdisposable)
            where=CREATE_CMD
            ;;
        edit)
            where=EDIT_CMD
            ;;
        --navbar|--virtualkeyboard)
            where=ONOFF_OPTION
            ;;
        --sysprop)
            where=SYSPROP_OPTION
            ;;
        --network-mode)
            where=NETWORK_MODE_OPTION
            ;;
        -*)
            where=OPTION
            ;;
        *)
            if [[ $where == CREATE_CMD ]]; then
                where=TEMPLATE_VALUE
            elif [[ $where == EDIT_CMD ]]; then
                where=VM_VALUE
            elif [[ $where == TEMPLATE_VALUE ]]; then
                where=VM_VALUE
            elif [[ $where == ONOFF_OPTION ]]; then
                where=ONOFF_VALUE
            elif [[ $where == SYSPROP_OPTION ]]; then
                where=SYSPROP_VALUE
            elif [[ $where == NETWORK_MODE_OPTION ]]; then
                where=NETWORK_MODE_VALUE
            else
                where=OPT_VALUE
            fi
            ;;
        esac
    done
    case "$where" in
    ONOFF_VALUE)
        COMPREPLY=( $(compgen -W "on off" -- "$cur") )
        return
        ;;
    SYSPROP_VALUE)
        _gmtool_sysprop_complete "$cur"
        return
        ;;
    NETWORK_MODE_VALUE)
        COMPREPLY=( $(compgen -W "nat bridge" -- "$cur") )
        return
        ;;
    VM_VALUE) #Do we really want that ?
        _gmtool_vm_complete "$cur"
        return
        ;;
    TEMPLATE_VALUE) #Do we really want that ?
        _gmtool_template_complete "$cur"
        return
        ;;
    OPTION)
        COMPREPLY=( $(compgen -W "--density --width --height --nbcpu --ram --navbar --virtualkeyboard --network-mode --bridged-if --sysprop --adb-serial-port" -- "$cur") )
        return
        ;;
    esac
}

_gmtool_admin_() {
    SUBCOMMANDS="clone create delete details edit factoryreset list logzip start startdisposable stop stopdisposable stopall templates"
    local i cur prev where
    i=$1
    sub="${COMP_WORDS[i]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ $i -eq $COMP_CWORD ]]; then
        COMPREPLY=( $(compgen -W "$SUBCOMMANDS" -- "$cur") )
        return
    else
        case "${sub}" in
        list)
            if [[ $((i+1)) -eq $COMP_CWORD ]]; then
                COMPREPLY=( $(compgen -W "--running --off" -- "$cur") )
            fi
            return
            ;;
        details)
            _gmtool_vm_complete "$cur"
            return
            ;;
        start|stop|stopdisposable|delete|factoryreset|clone)
            if [[ $((i+1)) -eq $COMP_CWORD ]]; then
                _gmtool_vm_complete "$cur"
            fi
            return
            ;;
        stopall)
            return
            ;;
        logzip)
            i=$((i+1))
            _gmtool_admin_logzip_ $i
            return
            ;;
        templates)
            i=$((i+1))
            _gmtool_admin_templates_ $i
            return
            ;;
        edit|create|startdisposable)
            i=$((i+1))
            _gmtool_admin_create_edit_startdisposable_ $i
            return
            ;;
        esac
    fi
}

_gmtool_admin_logzip_() {
    local i cur prev where
    i=$1
    where=FILE
    for ((; i <= COMP_CWORD; i++)); do
        cur="${COMP_WORDS[i]}"
        case "${cur}" in
        -*)
            where=OPTIONS
            ;;
        *)
            if [[ $where == OPTIONS ]]; then
                where=OPT_ARG
            else
                where=FILE
                break
            fi
            ;;
        esac
    done
    case "$where" in
    FILE)
        _adb_util_complete_local_file "$cur" "!*.zip"
        return
        ;;
    OPT_ARG)
        _gmtool_vm_complete "$cur"
        return
        ;;
    OPTIONS)
        COMPREPLY=( $(compgen -W "-n --name" -- "$cur") )
        return
        ;;
    esac
}

_gmtool_admin_templates_() {
    OPTIONS="--full --force-refresh -f"
    COMPREPLY=( $(compgen -W "$OPTIONS" -- "$cur") )
}

_gmtool_device_() {
    COMMANDS="adbconnect adbdisconnect flash install logcatclear logcatdump pull push"
    local i cur prev where sub
    i=$1
    where=OPTION
    for ((; i <= COMP_CWORD; i++)); do
        cur="${COMP_WORDS[i]}"
        case "${cur}" in
        -n|--name)
            where=OPT_NAME
            ;;
        -*)
            where=OPTIONS
            ;;
        *)
            if [[ $where == OPT_NAME ]]; then
                where=VIRTUAL_DEVICE
            else
                where=COMMANDS
                break
            fi
            ;;
        esac
    done
    case "$where" in
    COMMANDS)
        if [[ $i -eq $COMP_CWORD ]]; then
            COMPREPLY=( $(compgen -W "$COMMANDS" -- "$cur") )
            return
        else
            sub="${COMP_WORDS[i]}"
            cur="${COMP_WORDS[COMP_CWORD]}"
            i=$((i+1))
            case "$sub" in
            logcatdump|install|flash)
                _adb_util_complete_local_file "$cur"
                return
                ;;
            logcatclear|adbdisconnect)
                return
                ;;
            adbconnect)
                COMPREPLY=( $(compgen -W "--adb-serial-port" -- "$cur") )
                return
                ;;
            push)
                _adb_cmd_push none $i
                ;;
            pull)
                _adb_cmd_pull none $i
                ;;
            esac
        fi
        ;;
    OPTIONS)
        COMPREPLY=( $(compgen -W "-n --name --all --start" -- "$cur") )
        return
        ;;
    VIRTUAL_DEVICE)
        _gmtool_vm_complete $cur
        return
        ;;
    esac
}

_gmtool_filter_genymotion_vm() {
    # Expects vmname in stdin, prints vmname on stdout if it is a Genymotion VM
    local out
    while read vmname ; do
        out=$(vboxmanage guestproperty get "$vmname" vbox_graph_mode)
        if [ "$out" != 'No value set!' ] ; then
            echo $vmname
        fi
    done
}

_gmtool_vm_complete() {
    local cur devices IFS=$'\n'
    local -a toks
    local -a args
    cur="$1"
    _gmtool_compopt -o filenames
    devices=$(vboxmanage list vms | awk -F"\"" '{print $2}' | _gmtool_filter_genymotion_vm)
    COMPREPLY=( $(compgen -W "$devices" -- "$cur") )
}

_gmtool_template_complete() {
    local cur templates IFS=$'\n'
    local -a toks
    local -a args
    cur="$1"
    _gmtool_compopt -o filenames
    templates=$( gmtool admin templates | grep Name | sed 's/Name: //')
    COMPREPLY=( $(compgen -W "$templates" -- "$cur") )
}

_adb_cmd_push() {
    local serial IFS=$'\n' i cur

    serial=$1
    i=$2

    cur="${COMP_WORDS[COMP_CWORD]}"

    if [[ $COMP_CWORD == $i ]]; then
        _adb_util_complete_local_file "${cur}"
    elif [[ $COMP_CWORD == $(($i+1)) ]]; then
        if [ "${cur}" == "" ]; then
            cur="/"
        fi
        _adb_util_list_files $serial "${cur}"
    fi
}

_adb_cmd_pull() {
    local serial IFS=$'\n' i cur

    serial=$1
    i=$2

    cur="${COMP_WORDS[COMP_CWORD]}"

    if [[ $COMP_CWORD == $i ]]; then
        if [ "${cur}" == "" ]; then
            cur="/"
        fi
        _adb_util_list_files $serial "${cur}"
    elif [[ $COMP_CWORD == $(($i+1)) ]]; then
        _adb_util_complete_local_file "${cur}"
    fi
}

_adb_util_list_files() {
    local serial IFS=$'\n'
    local -a toks
    local -a args

    serial="$1"
    file="$2"

    if [ "$serial" != "none" ]; then
        args=(-s $serial)
    fi

    toks=( ${toks[@]-} $(
        command adb ${args[@]} shell ls -dF ${file}"*" '2>' /dev/null 2> /dev/null | tr -d '\r' | {
            while read -r tmp; do
                filetype=${tmp%% *}
                filename=${tmp:${#filetype}+1}
                if [[ ${filetype:${#filetype}-1:1} == d ]]; then
                    printf '%s/\n' "$filename"
                else
                    printf '%s\n' "$filename"
                fi
            done
        }
    ))

    # Since we're probably doing file completion here, don't add a space after.
    _gmtool_compopt -o nospace

    COMPREPLY=( ${COMPREPLY[@]:-} "${toks[@]}" )
}

# Complete a local file, similar to _filedir, but _filedir is not available out
# of the box on Mac OS X
# @param cur: current word being completed
# @param xspec (optional): exclusion filter pattern. Any file matching the pattern will be excluded
#   so "*.orig" will not list files with the .orig extension. Can be negated by prefixing with '!'.
_adb_util_complete_local_file() {
    local cur xspec i j IFS=$'\n'
    local -a dirs files

    cur=$1
    xspec=$2

    # Since we're probably doing file completion here, don't add a space after.
    if _gmtool_has_compopt ; then
        compopt -o plusdirs
        if [[ "${xspec}" == "" ]]; then
            COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -f -- "${cur}") )
        else
            compopt +o filenames
            COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -f -X "${xspec}" -- "${cur}") )
        fi
    else
        # Work-around for shells with no compopt

        dirs=( $(compgen -d -- "${cur}" ) )

        if [[ "${xspec}" == "" ]]; then
            files=( ${COMPREPLY[@]:-} $(compgen -f -- "${cur}") )
        else
            files=( ${COMPREPLY[@]:-} $(compgen -f -X "${xspec}" -- "${cur}") )
        fi

        COMPREPLY=( $(
            for i in "${files[@]}"; do
                local skip=
                for j in "${dirs[@]}"; do
                    if [[ $i == $j ]]; then
                        skip=1
                        break
                    fi
                done
                [[ -n $skip ]] || printf "%s\n" "$i"
            done
        ))

        COMPREPLY=( ${COMPREPLY[@]:-} $(
            for i in "${dirs[@]}"; do
                printf "%s/\n" "$i"
            done
        ))
    fi
}

complete -F _gmtool gmtool

# For Windows
complete -F _gmtool gmtool.exe
