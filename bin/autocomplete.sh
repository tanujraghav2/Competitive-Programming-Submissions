DIR="/home/anwailuisa/Projects/Competitive-Programming-Submissions"

function autocomplete {

    case ${COMP_LINE} in

    *fetch*)
        IFS=$'\n' tmp=($(compgen -W "$(ls $DIR/tmp/stash/)" -- ${COMP_WORDS[COMP_CWORD]}))
        COMPREPLY=("${tmp[@]// /\ }")
        ;;

    esac

}

complete -F autocomplete run
