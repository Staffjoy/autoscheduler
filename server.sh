#!/bin/bash
set -e

# 1) Run julia in parallel mode
# 2) Remove short log lines that are probably just new lines anyways
# 3)Filter out stupid gurobi server capacity
# 4) Add the environment to the log line
# 5) Write it to scheduler.log, but also add

julia -p `julia -e "print(Base.CPU_CORES)"` -e 'import Manager; Manager.run_server()' 2>&1 | while read a; do echo "staffjoy-scheduler-$ENV $a " | grep -v "Server capacity available" | grep -v "Not solved to optimality" | grep -v "Farkas proof" | grep -v "Gurobi reported infeasible or unbounded" | tee -a scheduler.log;  done
