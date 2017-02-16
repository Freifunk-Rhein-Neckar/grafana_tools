#!/usr/bin/env python3
import json
import requests
from contextlib import contextmanager
import time
import socket
import logging
import re

logger = logging.getLogger(__name__)

@contextmanager
def get_socket(host, port):
    sock = socket.socket()
    sock.settimeout(1)
    sock.connect((host, port))
    yield sock
    sock.close()

def write_to_graphite(data, prefix='ffrn'):
    now = time.time()
    with get_socket('s.ffrn.de', 2003) as s:
        for key, value in data.items():
            line = "%s.%s %s %s\n" % (prefix, key, value, now)
            try:
                line = line.encode('latin-1')
                s.sendall(line)
            except UnicodeEncodeError:
                continue

def main():
    time.sleep(10)
    logging.basicConfig(level=logging.WARN)

    URL = 'https://map.ffrn.de/data/nodes.json'

    trans_table = {
        0xe4: u'ae',
        0xf6: u'oe',
        0xfc: u'ue',
        0xdf: u'ss',
        0xc4: u'Ae',
        0xd6: u'Oe',
        0xdc: u'Ue',
    }

    gateways = []

    try:
        client_count = 0

        data = requests.get(URL, timeout=1).json()
        nodes = data['nodes']
        known_nodes = len(nodes.keys())
        online_nodes = 0
        update = {}
        gateway_count = 0
        for node_mac, node in nodes.items():
            try:
                hostname = node['nodeinfo']['hostname'].translate(trans_table)
                mac = node_mac

                flags = node['flags']
                if flags['online']:
                  online_nodes += 1

                if flags['gateway']:
                  gateway_count += 1
                  gateways.append(hostname)

                statistics = node['statistics']
                nodeinfo = node['nodeinfo']
                try:
                  loadavg = statistics['loadavg']
                  update['%s.%s.loadavg' % (mac, hostname)] = loadavg
                except KeyError:
                  pass
                try:
                  uptime = statistics['uptime']
                  update['%s.%s.uptime' % (mac, hostname)] = uptime
                except KeyError:
                  pass

                try:
                  clients = statistics['clients']
                  client_count += int(clients)
                  update['%s.%s.clients' % (mac, hostname)] = clients
                except KeyError:
                  pass

                try:
                  mem = statistics['memory_usage']
                  update['%s.%s.mem' % (mac, hostname)] = mem
                except KeyError:
                  pass


                try:
                  traffic = statistics['traffic']
                  for key in ['tx', 'rx', 'mgmt_tx', 'mgmt_rx', 'forward']:
                      update['%s.%s.traffic.%s.packets' % (mac, hostname, key)] = traffic[key]['packets']
                      update['%s.%s.traffic.%s.bytes' % (mac, hostname, key)] = traffic[key]['bytes']
                except KeyError:
                  pass
            except KeyError as e:
                print(time.time())
                print('error while reading ', node_mac)

        update['clients'] = client_count
        update['known_nodes'] = known_nodes
        update['online_nodes'] = online_nodes
        update['gateways'] = gateway_count
        write_to_graphite(update)
    except Exception as e:
        print(e)

if __name__ == "__main__":
    main()
