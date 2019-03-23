#!/bin/bash

TARGET="stats.ffrn.de 2003"

gawk -v interface=eth0 -v prefix=ffrn -v hostname=$(hostname -f) '/eth0/ { time = systime(); print prefix "." hostname "." interface ".rx.bytes " $2 " " time "\n" prefix "." hostname "." interface ".tx.bytes " $10 " " time "\n" prefix "." hostname "." interface ".rx.packets " $3 " " time "\n" prefix "." hostname "." interface ".tx.packets " $11 " " time "\n" }' /proc/net/dev | nc -q0 $TARGET

gawk -v interface=ffrn-br -v prefix=ffrn -v hostname=$(hostname -f) '/ffrn-br/ { time = systime(); print prefix "." hostname "." interface ".rx.bytes " $2 " " time "\n" prefix "." hostname "." interface ".tx.bytes " $10 " " time "\n" prefix "." hostname "." interface ".rx.packets " $3 " " time "\n" prefix "." hostname "." interface ".tx.packets " $11 " " time "\n" }' /proc/net/dev | nc -q0 $TARGET

gawk -v interface=ffrn-bat -v prefix=ffrn -v hostname=$(hostname -f) '/ffrn-bat/ { time = systime(); print prefix "." hostname "." interface ".rx.bytes " $2 " " time "\n" prefix "." hostname "." interface ".tx.bytes " $10 " " time "\n" prefix "." hostname "." interface ".rx.packets " $3 " " time "\n" prefix "." hostname "." interface ".tx.packets " $11 " " time "\n" }' /proc/net/dev | nc -q0 $TARGET

gawk -v interface=ffrn-vpn -v prefix=ffrn -v hostname=$(hostname -f) '/ffrn-vpn/ { time = systime(); print prefix "." hostname "." interface ".rx.bytes " $2 " " time "\n" prefix "." hostname "." interface ".tx.bytes " $10 " " time "\n" prefix "." hostname "." interface ".rx.packets " $3 " " time "\n" prefix "." hostname "." interface ".tx.packets " $11 " " time "\n" }' /proc/net/dev | nc -q0 $TARGET

gawk -v interface=v6upstream -v prefix=ffrn -v hostname=$(hostname -f) '/v6upstream/ { time = systime(); print prefix "." hostname "." interface ".rx.bytes " $2 " " time "\n" prefix "." hostname "." interface ".tx.bytes " $10 " " time "\n" prefix "." hostname "." interface ".rx.packets " $3 " " time "\n" prefix "." hostname "." interface ".tx.packets " $11 " " time "\n" }' /proc/net/dev | nc -q0 $TARGET

gawk -v interface=mapbone -v prefix=ffrn -v hostname=$(hostname -f) '/mapbone/ { time = systime(); print prefix "." hostname "." interface ".rx.bytes " $2 " " time "\n" prefix "." hostname "." interface ".tx.bytes " $10 " " time "\n" prefix "." hostname "." interface ".rx.packets " $3 " " time "\n" prefix "." hostname "." interface ".tx.packets " $11 " " time "\n" }' /proc/net/dev | nc -q0 $TARGET

gawk -v prefix=ffrn -v hostname=$(hostname -f) '{ time = systime(); print prefix "." hostname ".load.1 " $1 " " time "\n" prefix "." hostname ".load.5 " $2 " " time "\n" prefix "." hostname ".load.15 " $3 " " time "\n" }' /proc/loadavg | nc -q0 $TARGET

gawk -v prefix=ffrn -v hostname=$(hostname -f) '{ time = systime(); print prefix "." hostname ".netfilter.conntrack.count " $1 " " time}' /proc/sys/net/netfilter/nf_conntrack_count | nc -q0 $TARGET

/usr/bin/python /root/ff-tools/fastd/fastd-statistics.py -s /var/run/fastd.sock | gawk -v prefix=ffrn -v hostname=$(hostname -f) '{ time = systime(); print prefix "." hostname ".fastd-peers " $1 " " time "\n" prefix "." hostname ".fastd-connections " $2 " " time "\n" }' | nc -q0 $TARGET

/usr/bin/python /opt/grafana_tools/dhcp_leases.py | nc -q0 $TARGET
