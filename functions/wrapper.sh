#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2016-2020 The Debian Live team
## Copyright (C) 2006-2015 Daniel Baumann <mail@daniel-baumann.ch>
##
## This program comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Apt ()
{
	local CHROOT="${1}"
	local MODE="${2}"
	shift 2

	if [ "${MODE}" = "update" ]
	then
		# Normalize Check-Valid-Until across every deb822 source before updating: a
		# frozen build has the same mirror in two sources files with the field set
		# inconsistently (the derivative's frozen derivative.sources 'no' vs the base
		# debian.sources this stage writes from the same mirror without it), which apt
		# rejects under APT::Update::Error-Mode=any. Strip it so they agree; the expired
		# Release stays tolerated via Acquire::Check-Valid-Until in APT_UPDATE_OPTIONS.
		find "${CHROOT}/etc/apt/sources.list.d/" -maxdepth 1 -name '*.sources' \
			-exec sed -i -e '/^Check-Valid-Until:/Id' -- {} + 2>/dev/null || true
	fi

	case "${LB_APT}" in
		apt|apt-get)
			if [ "${MODE}" = "update" ]
			then
				Chroot ${CHROOT} apt-get ${APT_OPTIONS} ${APT_UPDATE_OPTIONS} ${MODE} "${@}"
			else
				Chroot ${CHROOT} apt-get ${APT_OPTIONS} ${MODE} "${@}"
			fi
			;;

		aptitude)
			Chroot ${CHROOT} aptitude ${APTITUDE_OPTIONS} ${MODE} "${@}"
			;;
	esac
}
