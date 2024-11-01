#!/bin/bash

# Copyright (c) 2024 Andrew Clark (FL4SHK)

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

printerr() {
	echo "$@" >&2
}

print_usage() {
	printerr "Valid Commands (arguments listed before ':'):"
	printerr "help: show this help"
	printerr "grep-list-sinks:"
	printerr "  * Run 'pacmd list-sinks | grep --color '\(index\|name\):'"
	printerr "  * This is helpful for finding your desired"
	printerr "    'speakers-sink-name' argument"
	printerr "    to the 'create-merged-sink' command."
	printerr "grep-list-sources:"
	printerr "  * Run 'pacmd list-sources | grep --color '\(index\|name\):'"
	printerr "  * This is helpful for finding your desired"
	printerr "    'mic-source-name' argument"
	printerr "    to the 'create-merged-sink' command."
	printerr "create-merged-sink merged-sink-name speakers-sink-name mic-source-name:"
	printerr "  * Create a sink that takes input from both"
	printerr "    your speakers (or any other audio sink)"
	printerr "    and your microphone (or any other audio source)"
	printerr "  * 'speakers-sink-name' should be the right-hand-side of"
	printerr "    your desired 'sample_sink' in the 'name: <sample_sink>'"
	printerr "    output by a previous run of of 'grep-list-sinks'"
	printerr "    (So remove the '<' and '>' from '<sample_sink>'"
	printerr "    and keep the rest)."
	printerr "  * 'mic-source-name' should be the right-hand-side of"
	printerr "    your desired 'sample_source' in the "
	printerr "    'name: <sample_source>'"
	printerr "    output by a previous run of of 'grep-list-sources'"
	printerr "    (So remove the '<' and '>' from '<sample_source>'"
	printerr "    and keep the rest)."
	printerr "unload:"
	printerr "  * Run 'pacmd unload-module module-remap-sink'"
	printerr "  * Run 'pacmd unload-module module-loopback'"
	printerr "  * This removes the audio streams created by"
	printerr "    previous runs of the 'create-merged-sink' command."
}
bad_args() {
	printerr "Invalid arguments."
	print_usage
	exit 1
}

case "$1" in
	help)
		print_usage
		exit 0
		;;
	grep-list-sinks)
		pacmd list-sinks | grep --color '\(index\|name\):'
		;;
	grep-list-sources)
		pacmd list-sources | grep --color '\(index\|name\):'
		;;
	create-merged-sink)
		if (( $# != 4 )); then
			bad_args
		else # if (( $# == 4 )); then
			# "$2" is merged-sink-name
			# "$3" is speakers-sink-name
			# "$4" is mic-source-name
			pacmd load-module module-null-sink sink_name="$2-null"
			pacmd load-module module-remap-sink sink_name="$2" master="$2-null"
			pacmd load-module module-loopback source="$4" sink="$2-null"
			pacmd load-module module-loopback source="$2.monitor" sink="$3"
			pacmd load-module module-combine-sink sink_name="$2-nullandmain" slaves="$3","$2-null"
		fi
		;;
	unload)
		if (( $# != 1 )); then
			bad_args
		else
			pacmd unload-module module-null-sink
			pacmd unload-module module-remap-sink
			pacmd unload-module module-loopback
		fi
		;;
	*)
		bad_args
		;;
esac
