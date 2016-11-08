#!/bin/sh

if [ -z "$NOTES_DIR" ]; then
	NOTES_DIR=~/Dropbox/notes
fi

main() {
	if [ $# -lt 1 ]; then
		echo "Usage: notes.sh [OPTIONS] <name>"
		echo "Available options:"
		echo "    -n --new (default)"
		echo "    -l --ls --list"
		echo "    -s --search"
		echo "    -r --rm --remove -d --delete"
		exit 0
	fi

	local func="new"
	local args=""
	local name=""

	for arg in "$@"; do
		case $arg in
			-n|--new )
				func="new"
				;;
			-l|--ls|--list )
				func="list"
				;;
			-s|--search )
				func="search"
				;;
			-r|--rm|--remove|-d|--delete )
				func="delete"
				;;
			-* )
				echo "Unknown option $arg"
				exit 1
				;;
			* )
				if [ -n "$name" ]; then
					echo "Too many arguments!"
					exit 1
				fi
				name="$arg"
				;;
		esac
	done

	eval note_$func $args $name
}

note_new() {
	local name="$1"
	local count=$(note_list $name | wc -w)
	if [ $count -gt 1 ]; then
		note_list $name
	elif [ $count -eq 0 ]; then
		eval $EDITOR "$NOTES_DIR/$name.md"
	else
		eval $EDITOR "$NOTES_DIR/$(note_list $name)"
	fi
}

note_delete() {
	local name="$1"
	local count=$(note_list $name | wc -w)
	if [ $count -gt 1 ]; then
		note_list $name
	elif [ $count -eq 0 ]; then
		rm "$NOTES_DIR/$name.md"
	else
		rm "$NOTES_DIR/$(note_list $name)"
	fi
}

note_list() {
	cd $NOTES_DIR
	if [ $# = 0 ]; then
		ls *.md
	else
		files=$(ls -1 *.md | grep -- "$*")
		if [ -n "$files" ]; then
			ls $files
		fi
	fi
}

note_search() {
	if command -v ag >/dev/null 2>&1; then
		ag "$*" $NOTES_DIR
	else
		grep -r "$*" $NOTES_DIR
	fi
}

main "$@"
