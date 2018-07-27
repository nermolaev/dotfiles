#!/bin/sh

alias av=venv-activate
alias avenv=venv-activate
alias rmvenv=venv-destroy

# find and activate a python virtualenv
function venv-activate {
	if [ -n "$VIRTUAL_ENV" ]; then
		echo "A virtualenv is already active!"
		return 1
	fi

	eval $(venv-locate $PWD "$@")

	if [ -z "$venv" ]; then
		echo "Couldn't find a virtualenv in cwd!"
		venv-create -a "$@" || return $?
		venv-activate "$@"
		return $?
	fi

	local relpath=$(realpath --relative-to=$PWD $venv)
	if [[ "$relpath" =~ ^\.\. ]]; then
		relpath=$venv
	fi
	echo -n "Activating virtualenv: $relpath"
	echo " - $($venv/bin/python --version 2>&1)"
	echo "Run \`deactivate\` to exit the virtualenv."
	. $venv/bin/activate
	_set_ps1
}

function venv-locate {
	local dir="${1:-$PWD}"
	local name="$2"
	local venv
	local venv_name
	if [ -d $dir/.tox ]; then
		if [ -n "$name" ]; then
			if [ ! -d "$dir/.tox/$name" ]; then
				echo "No tox environment $name found!" >&2
				return 0
			fi
			venv=$dir/.tox/$name
		else
			venv=$(find $dir/.tox -mindepth 1 -maxdepth 1 -name 'py*' | sort | tail -1)
		fi
		venv_name="$(basename $dir)/$(basename $venv)"
	elif [ -f $dir/.virtualenv/bin/activate ]; then
		venv=$dir/.virtualenv
		venv_name=$(basename $dir)
	elif [ -f $dir/.venv/bin/activate ]; then
		venv=$dir/.venv
		venv_name=$(basename $dir)
	elif [ -f $dir/venv/bin/activate ]; then
		venv=$dir/venv
		venv_name=$(basename $dir)
	elif [ -f $dir/bin/activate ]; then
		venv=$dir
		venv_name=$(basename $dir)
	fi
	if [ -n "$venv_name" ]; then
		echo "local venv=$venv"
		echo "export VIRTUAL_ENV_NAME=$venv_name"
		return 0
	else
		return 1
	fi
}

function venv-create {
	local python='python3'
	local ask='no'
	local cmd
	local venv

	while [ $# -gt 0 ]; do
		arg="$1"
		case $arg in
			-a|--ask )
				ask='yes'
				;;
			-p|--python )
				shift
				python="$1"
				;;
			-p* )
				python="${1:2}"
				;;
			-2|--two )
				python='python2'
				;;
			-3|--three )
				python='python3'
				;;
			-* )
				echo "Unknown option: $arg"
				return 1
				;;
			* )
				if [ -n "$venv" ]; then
					echo "Extra argument received: $arg"
					return 1
				fi
				venv="$1"
				;;
		esac
		shift
	done

	if echo "$python" | grep -qP '^[\d\.]+$'; then
		python="python${python}"
	fi

	if echo "$python" | grep -q '^python3'; then
		cmd="$python -m venv"
	else
		cmd="virtualenv -p $python"
	fi

	if [ -z "$venv" ] || [ "$venv" = "$PWD" ] || [ "$venv" = '.' ]; then
		venv=".venv"
	fi

	echo "Creating virtualenv in '$venv' using $($python --version 2>&1) ..."
	if [ "$ask" = 'yes' ]; then
		read -p "Confirm [Y/n] "
		if [ -n "$REPLY" ] && ! [[ "$REPLY" =~ ^[Yy] ]]; then
			return 1
		fi
	fi
	$cmd $venv || return 1
	$venv/bin/pip install --upgrade pip setuptools
}

function venv-destroy {
	local ask='no'
	local dir

	while [ $# -gt 0 ]; do
		arg="$1"
		case $arg in
			-a|--ask )
				ask='yes'
				;;
			-* )
				echo "Unknown option: $arg"
				return 1
				;;
			* )
				if [ -n "$dir" ]; then
					echo "Extra argument received: $arg"
					return 1
				fi
				dir="$arg"
				break
				;;
		esac
		shift
	done

	if [ -z "$dir" ]; then
		dir="$PWD"
	fi

	eval $(venv-locate $dir)
	if [ -z "$venv" ]; then
		echo "No virtualenv found!"
		return 0
	fi

	if [ "$ask" = 'yes' ]; then
		read -p "Remove virtualenv '$venv'? [Y/n] "
		if [ -n "$REPLY" ] && ! [[ "$REPLY" =~ ^[Yy] ]]; then
			return 1
		fi
	fi

	if [ -n "$VIRTUAL_ENV" ]; then
		deactivate
		_set_ps1
	fi
	echo "Removing $venv ..."
	rm -rf $venv
}