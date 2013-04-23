#!/bin/bash -x

p1=0
p2=0

trap 'kill $p1 $p2; echo; exit' SIGINT SIGTERM

sass -w style.sass:style.css &
p1=$!

coffee -wc main.coffee &
p2=$!

wait $p1 $p2

