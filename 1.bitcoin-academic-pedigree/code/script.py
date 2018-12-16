# -*- coding: utf-8 -*-

import requests
import json
from pprint import pprint

if __name__ == '__main__':

    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('-m', '--mode', default='chain',
                        type=str, help='methods')
    parser.add_argument('-c', '--config', default='default',
                        type=str, help='ipconfig')

    args = parser.parse_args()

    config = json.load(open('./config/' + args.config+'.json', 'r'))
    ip_port = config['ip']+":"+config['port']

    mode = args.mode
    if mode == 'chain' or mode == 'mine':
        ret = requests.get("http://%s/" % (ip_port)+mode).json()

    elif mode == 'resolve':
        ret = requests.get("http://%s/nodes/resolve" % ip_port).json()

    elif mode == 'send':
        order = {'sender': "someone-address",
                 'recipient': "someone-other-address",
                 'amount': 5
                 }

        pprint(order)

        ret = requests.post("http://%s/transactions/new" %
                            ip_port, data=order).json()

    elif mode == 'register':

        nodes_order = json.load(open('./config/nodes.json', 'r'))

        ret = requests.post("http://%s/nodes/register" %
                            ip_port, data=nodes_order).json()

    pprint(ret)
