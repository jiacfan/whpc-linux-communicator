#!/bin/bash
# end the task with task id.

. common.sh

[ -z "$1" ] && echo "task id not specified" && exit 202
[ -z "$2" ] && echo "process id not specified" && exit 202
[ -z "$3" ] && echo "forced not specified" && exit 202

taskId=$1
processId=$2
forced=$3

if $CGInstalled; then
	groupName=$(GetCGroupName "$taskId")
	group=$CGroupSubSys:$groupName
	tasks=$(GetCpusetTasksFile "$groupName")
	freezerState=$(GetFreezerStateFile "$groupName")
	[ ! -f "$tasks" ] && echo "$tasks doesn't exist" && exit 200
	[ ! -f "$freezerState" ] && echo "$freezerState doesn't exist" && exit 201

	# freeze the task
	echo FROZEN > "$freezerState"

	maxLoop=20
	while [ -f "$freezerState" ] && ! grep -Fxq FROZEN "$freezerState" && [ $maxLoop -gt 0 ]
	do
		sleep .1
		((maxLoop--))
	done

	# kill all tasks
	while read pid || [ -n "$pid" ]
	do
		if [ "$forced" == "1" ]; then
			[ -d "/proc/$pid" ] && kill -9 "$pid"
		else
			[ -d "/proc/$pid" ] && kill -SIGINT "$pid"
		fi
	done < "$tasks"

	# resume tasks
	echo THAWED > "$freezerState"

	maxLoop=20
	while [ -f "$freezerState" ] && ! grep -Fxq THAWED "$freezerState" && [ $maxLoop -gt 0 ]
	do
		sleep .1
		((maxLoop--))
	done
else
	if [ "$forced" == "1" ]; then
		kill -s 9 "$(pstree -l -p "$processId" | grep "([[:digit:]]*)" -o | tr -d '()')"
	else
		kill -s SIGINT "$(pstree -l -p "$processId" | grep "([[:digit:]]*)" -o | tr -d '()')"
	fi
fi

exit 0
