#!/bin/bash
set -euo pipefail

# This script safely installs pip dependencies.
# It expects the DEPENDENCIES environment variable to be set.
# It splits the dependencies, expands globs for local wheel files,
# and explicitly blocks unsafe local dependency sources like editable
# installs or requirement files, ensuring no arbitrary code execution
# from checked-out repositories.

if [ -z "${DEPENDENCIES:-}" ]; then
	echo "No dependencies provided."
	exit 0
fi

# We use read to split DEPENDENCIES on whitespace into an array
read -r -a raw_args <<<"$DEPENDENCIES"

args=()
for arg in "${raw_args[@]}"; do
	# Block unsafe arguments
	case "$arg" in
	-e | -e* | --editable | --editable=* | -r | -r* | --requirement | --requirement=* | -c | -c* | --constraint | --constraint=*)
		echo "::error::Unsupported pip option in dependencies: $arg"
		echo "::error::This action refuses editable installs, requirement files, and constraint files to avoid executing checked-out code."
		exit 1
		;;
	file:* | file://*)
		echo "::error::Local file URLs are not allowed in dependencies: $arg"
		exit 1
		;;
	esac

	is_path_like=false
	case "$arg" in
	. | ./* | ../* | /* | */* | *.whl | *.tar.gz | *.zip)
		is_path_like=true
		;;
	esac

	has_glob=false
	case "$arg" in
	*'*'* | *'?'*)
		# Note: '[' is intentionally excluded from glob detection because it
		# is used in Python extras syntax (e.g. requests[security], .[dev,test])
		# and character-class globs like [abc] are not a realistic use case here.
		has_glob=true
		;;
	esac

	# Handle glob expansion for path-like arguments
	if [ "$is_path_like" = true ] && [ "$has_glob" = true ]; then
		matches=()
		while IFS= read -r match; do
			if [ -n "$match" ]; then
				matches+=("$match")
			fi
		done < <(compgen -G "$arg" || true)

		if [ "${#matches[@]}" -eq 0 ]; then
			# No match found, just pass the literal arg (pip will likely fail, which is fine)
			args+=("$arg")
			continue
		fi

		for match in "${matches[@]}"; do
			case "$match" in
			*.whl)
				args+=("$match")
				;;
			*)
				echo "::error::Only local wheel files may be installed from the checkout: $match"
				exit 1
				;;
			esac
		done
		continue
	fi

	# Handle literal path-like arguments
	if [ "$is_path_like" = true ]; then
		case "$arg" in
		*.whl)
			args+=("$arg")
			;;
		*)
			echo "::error::Only local wheel files may be installed from the checkout: $arg"
			exit 1
			;;
		esac
		continue
	fi

	# Regular package specifier or flag
	args+=("$arg")
done

echo "Running: python -I -m pip install ${args[*]}"
python -I -m pip install "${args[@]}"
