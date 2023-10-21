#!/usr/bin/env bash

DIR="/home/anwailuisa/Projects/Competitive-Programming-Submissions"

AUTHOR="Tanuj Raghav <tanujraghav>"
TIMESTAMP=`date +%s`

INDEX="$DIR/README.md"

TEMPLATE="$DIR/lib/master.cpp"

SOURCE="$DIR/tmp/src.cpp"
OUTPUT="$DIR/tmp/.output.out"
INPUT="$DIR/tmp/.input.in"

PROBLEM="`sed -n 2p "$SOURCE" | cut --complement -d' ' -f1,2`"
PROBLEM_STATEMENT="`sed -n 3p "$SOURCE" | cut --complement -d' ' -f1,2,3`"

LOG="$DIR/tmp/.log"

TCGEN="$DIR/tmp/stresstest/generator.cpp"
OUTPUT_TCGEN="$DIR/tmp/stresstest/.output_generator.out"

BRUTE="$DIR/tmp/stresstest/bruteforce.cpp"
OUTPUT_BRUTE="$DIR/tmp/stresstest/.output_bruteforce.out"

TMP="$DIR/tmp/.tmp"
TMP_BRUTE="$DIR/tmp/stresstest/.tmp_bruteforce"

function clear {

	cp "$TEMPLATE" "$SOURCE"
	echo -n > "$INPUT"

}

function save {

	SUBMISSION="$DIR/src/$PROBLEM.cpp"
	cp "$SOURCE" "$SUBMISSION"

	sed -i "1a \ \*\tAuthor: $AUTHOR" "$SUBMISSION"
	sed -i "2a \ \*" "$SUBMISSION"

	sed -i "3a \ \*\tCreated: `date -d@$TIMESTAMP +'%A, %B %d, %Y %t %T %Z'`" "$SUBMISSION"
	sed -i "4a \ \*" "$SUBMISSION"


	TALLY=`cat $DIR/tmp/.tally`

	if [ -n "$1" ]; then
		sed -i "5a |&#x2605; **$TALLY**|`date -d@$TIMESTAMP \"+%b. %d, &nbsp; %R\"`|[$PROBLEM]($PROBLEM_STATEMENT)|" "$INDEX"

	else
		sed -i "5a |**$TALLY**|`date -d@$TIMESTAMP \"+%b. %d, &nbsp; %R\"`|[$PROBLEM]($PROBLEM_STATEMENT)|" "$INDEX"

	fi

	echo $(($TALLY+1)) > "$DIR/tmp/.tally"


	cd "$DIR" >/dev/null

	git add "$SUBMISSION" "$INDEX"

	COMMIT_MSG="$DIR/tmp/.commit.msg"

	echo ":sparkles: Submission #$TALLY" > "$COMMIT_MSG"
	echo `sed -n 6p "$SUBMISSION" | cut --complement -d'	' -f1` >> "$COMMIT_MSG"
	echo `sed -n 7p "$SUBMISSION" | cut --complement -d'	' -f1` >> "$COMMIT_MSG"

	git commit --quiet -F "$COMMIT_MSG"

	git log --decorate --max-count=1 | tail -n+5

	cd - >/dev/null


	clear
	rm "$COMMIT_MSG"

}

function stash {

	BUFFER="$DIR/tmp/stash/$PROBLEM.cpp"
	cp "$SOURCE" "$BUFFER"


	[[ -n "$1" ]] && echo -ne "\n// Comment: $1" >> "$BUFFER"

	echo -ne "\n/***INPUT***\n`cat "$INPUT"`\n*/" >> "$BUFFER"


	clear

}

function fetch {

	[[ -z "$1" ]] && echo -e "\e[1;31m[!] ERROR-404\e[0m" && exit


	BUFFER="$DIR/tmp/stash/$1"

	LN=`grep -n "/***INPUT***" "$BUFFER" | cut -d: -f1`
	i=2


	if grep -q "Comment: " "$BUFFER"; then
		echo -e "\e[1;32mComment:\e[0m" `head -n$(($LN-1)) "$BUFFER" | tail -n1 | cut -d' ' --complement -f1,2`
		i=3
	fi


	head -n$(($LN-$i)) "$BUFFER" > "$SOURCE"
	tail -n+$(($LN+1)) "$BUFFER" | head -n-1 > "$INPUT"

	rm "$BUFFER"

}

function new {

	diff -qZ "$TEMPLATE" "$SOURCE" >/dev/null || stash


	if [ -n "$1" ]; then
		sed -i "2s/.*/&$1/" "$SOURCE"

	fi

}

function stresstest {

	unbuffer g++ -o "$OUTPUT_TCGEN" "$TCGEN" 2>&1 | tee "$LOG"
	[[ `grep "error" "$LOG"` ]] && exit

	unbuffer g++ -o "$OUTPUT_BRUTE" "$BRUTE" 2>&1 | tee "$LOG"
	[[ `grep "error" "$LOG"` ]] && exit

	unbuffer g++ -o "$OUTPUT" "$SOURCE" 2>&1 | tee "$LOG"
	[[ `grep "error" "$LOG"` ]] && exit


	i=0

	while true; do

		"$OUTPUT_TCGEN" `uuidgen` > "$INPUT"
		if [ $? -ne 0 ]; then
			echo -e "\e[1;31mRuntime Error\e[0m: Testcase Generator"
			exit
		fi

		"$OUTPUT" < "$INPUT" > "$TMP"
		if [ $? -ne 0 ]; then
			echo -e "\e[1;31mRuntime Error\e[0m: Source File"
			exit
		fi

		"$OUTPUT_BRUTE" < "$INPUT" > "$TMP_BRUTE"
		if [ $? -ne 0 ]; then
			echo -e "\e[1;31mRuntime Error\e[0m: Bruteforce Solution"
			exit
		fi

		echo -en "\rPassed Test: \e[1;32m$((i++))\e[0m"

		diff -qZ "$TMP" "$TMP_BRUTE" >/dev/null || break

	done


	echo -e "\n\n\e[1;31mWrong Answer\e[0m on the following testcase!"
	cat "$INPUT"
	echo

	echo -e "\n\e[1;31mSource File                   \e[0m| \e[1;32mBruteforce Solution  \e[0m"
	echo "------------------------------+------------------------------"
	diff --width=67 -yZ "$TMP" "$TMP_BRUTE"

	echo -n > "$INPUT"

}

function main {

	COMPILATION_FLAGS=""

	if [[ "$1" == "verbose" ]]; then
		COMPILATION_FLAGS="-O2 -pedantic -std=c++17
		-Wall -Wextra -Wshadow -Wformat=2 -Wfloat-equal -Wlogical-op -Wshift-overflow=2 -Wduplicated-cond -Wcast-qual -Wcast-align \
		-D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 \
		-fsanitize=address -fsanitize=undefined -fno-sanitize-recover -fstack-protector"
	fi

	unbuffer g++ `echo "$COMPILATION_FLAGS"` -o "$OUTPUT" "$SOURCE" 2>&1 | tee "$LOG"


	if ! grep -q "error" "$LOG"; then

		if [[ "$1" == "interactive" ]]; then
			echo "Interactive Input:"
			"$OUTPUT"

		else
			"$OUTPUT" < "$INPUT"

		fi

	fi

}

case $1 in

	save)
		save "${*:2}"
		;;

	stash)
		stash "${*:2}"
		;;

	fetch)
		fetch "${*:2}"
		;;

	test)
		stresstest
		;;
	
	clear)
		clear
		;;

	new)
		new "${*:2}"
		;;

	*)
		main "$1"
		;;

esac

rm -f "$OUTPUT_TCGEN" "$OUTPUT_BRUTE" "$OUTPUT" "$LOG" "$TMP" "$TMP_BRUTE" 
