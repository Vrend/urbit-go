#!/bin/bash

# Copyright (C) 2021 Vrend
#
# This file is part of urbit-go.
#
# urbit-go is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# urbit-go is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with urbit-go. If not, see <https://www.gnu.org/licenses/>.

# Taken and modified from ~timluc-miptev's Gall Guide https://github.com/timlucmiptev/gall-guide/blob/master/install.sh

usage() {
	printf "Usage: $0 -r|-w -d URBIT_HOME_DIRECTORY \n(-d: your urbit directory)\n(-r: copy from urbit directory to repository folder)\n(-w: copy from repository folder to urbit directory)\n" 1>&2
	exit 1
}

if [ "$#" -ne 3 ]; then
	usage
fi

while getopts rwd: flag
do
	case "${flag}" in
		d) directory=${OPTARG};;
		r) action=0;;
		w) action=1;;
	esac
done

if [ $action == 0 ]; then
	rsync $directory/urbit-go/app/urbit-go.hoon ./app
	rsync $directory/urbit-go/gen/urbit-go-test.hoon ./gen
	rsync $directory/urbit-go/lib/urbit-go.hoon ./lib
	rsync $directory/urbit-go/sur/urbit-go.hoon ./sur
	rsync $directory/urbit-go/mar/urbit-go-action.hoon ./mar
	rsync $directory/urbit-go/mar/urbit-go-game.hoon ./mar
	cp $directory/urbit-go/desk.bill .
	cp $directory/urbit-go/desk.docket-0 .
	cp $directory/urbit-go/desk.ship .
	cp $directory/urbit-go/sys.kelvin .
else
	rsync ./app/urbit-go.hoon $directory/urbit-go/app
	rsync ./gen/urbit-go-test.hoon $directory/urbit-go/gen
	rsync ./lib/urbit-go.hoon $directory/urbit-go/lib
	rsync ./sur/urbit-go.hoon $directory/urbit-go/sur
	rsync ./mar/urbit-go-action.hoon $directory/urbit-go/mar
	rsync ./mar/urbit-go-game.hoon $directory/urbit-go/mar
	rsync ./mar/urbit-go-challenge.hoon $directory/urbit-go/mar
	rsync ./mar/urbit-go-challenges.hoon $directory/urbit-go/mar
	rsync ./mar/urbit-go-games.hoon $directory/urbit-go/mar
	cp ./desk.bill $directory/urbit-go
	cp ./desk.docket-0 $directory/urbit-go
	cp ./desk.ship $directory/urbit-go
	cp ./sys.kelvin $directory/urbit-go
fi
