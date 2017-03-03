#!/bin/sh
set -e

julia -e 'Pkg.add("Gurobi")'
julia -e 'Pkg.add("JuMP")'
julia -e 'Pkg.add("JSON")'
julia -e 'Pkg.add("Logging")'
julia -e 'Pkg.add("Requests")'
julia -e 'Pkg.add("HttpServer")'
julia -e 'Pkg.add("Cbc")'