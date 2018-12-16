# -*- coding: utf-8 -*-

import hashlib
import json
from time import time
from typing import Any, Dict, List, Optional
from urllib.parse import urlparse
from uuid import uuid4

import requests
from flask import Flask, jsonify, request


class Blockchain:
    def __init__(self):
        self.current_transactions = []
        self.chain = []
        self.nodes = set()

        # 创建创世块
        self.new_block(1, time(), self.current_transactions,
                       previous_hash='1', proof=100)

    def register_node(self, address: str) -> None:
        """
        Add a new node to the list of nodes

        :param address: Address of node. Eg. 'http://192.168.0.5:5000'
        """
        parsed_url = urlparse(address)
        print(parsed_url)
        self.nodes.add(parsed_url.netloc)

    def new_transaction(self, sender: str, recipient: str, amount: int) -> int:
        """
        生成新交易信息，信息将加入到下一个待挖的区块中

        :param sender: Address of the Sender
        :param recipient: Address of the Recipient
        :param amount: Amount
        :return: The index of the Block that will hold this transaction
        """
        self.current_transactions.append({
            'sender': sender,
            'recipient': recipient,
            'amount': amount,
        })

        return self.last_block['index'] + 1

    def new_block(self, index, timestamp, current_transactions,
                  previous_hash, proof: int):
        """
        生成新块

        :param proof: The proof given by the Proof of Work algorithm
        :param previous_hash: Hash of previous Block
        :return: New Block
        """

        block = {
            'index': index,
            'timestamp': timestamp,
            'transactions': current_transactions,
            'proof': proof,
            'previous_hash': previous_hash or self.hash(self.chain[-1]),
        }

        # Reset the current list of transactions
        self.current_transactions = []

        self.chain.append(block)
        return block

    def new_candidate_block(self, index, timestamp, current_transactions,
                            previous_hash):
        """
        生成新块

        :param proof: The proof given by the Proof of Work algorithm
        :param previous_hash: Hash of previous Block
        :return: New Block
        """
        block = {
            'index': index,
            'timestamp': timestamp,
            'transactions': current_transactions,
            'previous_hash': previous_hash,
            'proof': ''
        }

        return block

    @property
    def last_block(self) -> Dict[str, Any]:
        return self.chain[-1]

    @staticmethod
    def hash(block: Dict[str, Any]) -> str:
        """
        生成块的 SHA-256 hash值

        :param block: Block
        """

        # We must make sure that the Dictionary is Ordered, or we'll have inconsistent hashes
        block_string = json.dumps(block, sort_keys=True).encode()
        return hashlib.sha256(block_string).hexdigest()

    @staticmethod
    def get_hash_block_proof(block_tmp, proof):

        block_tmp['proof'] = proof

        guess_hash = Blockchain.hash(block_tmp)
        return guess_hash

    @staticmethod
    def valid_proof(block_tmp, proof: int) -> bool:
        """
        验证证明: 是否hash(last_proof, proof)以4个0开头

        :param last_proof: Previous Proof
        :param proof: Current Proof
        :return: True if correct, False if not.
        """
        # guess = f'{last_proof}{proof}'.encode()
        # guess = (str(block_tmp) + str(proof)).encode()
        # guess_hash = hashlib.sha256(guess).hexdigest()
        # return guess_hash[:4] == "0000"

        guess_hash = Blockchain.get_hash_block_proof(block_tmp, proof)
        return guess_hash[:4] == "0000"

    def proof_of_work(self, block_tmp) -> int:
        """
        简单的工作量证明:
         - 查找一个 p 使得 hash 以4个0开头
        """

        proof = 0
        while self.valid_proof(block_tmp, proof) is False:
            proof += 1

        return proof

    def valid_chain(self, chain: List[Dict[str, Any]]) -> bool:
        """
        Determine if a given blockchain is valid

        :param chain: A blockchain
        :return: True if valid, False if not
        """

        last_block = chain[0]
        current_index = 1

        while current_index < len(chain):
            block = chain[current_index]
            # print(f'{last_block}')
            # print(f'{block}')
            print(last_block)
            print(block)
            print("\n-----------\n")
            # Check that the hash of the block is correct
            if block['previous_hash'] != self.hash(last_block):
                return False

            # Check that the Proof of Work is correct
            block_tmp = self.new_candidate_block(block['index'],
                                                 block['timestamp'],
                                                 block['transactions'],
                                                 block['previous_hash'])

            if not self.valid_proof(block_tmp, block['proof']):
                return False

            last_block = block
            current_index += 1

        return True

    def resolve_conflicts(self) -> bool:
        """
        共识算法解决冲突
        使用网络中最长的链.

        :return:  如果链被取代返回 True, 否则为False
        """

        neighbours = self.nodes
        new_chain = None

        # We're only looking for chains longer than ours
        max_length = len(self.chain)

        # Grab and verify the chains from all the nodes in our network
        for node in neighbours:
            # response = requests.get(f'http://{node}/chain')
            try:
                response = requests.get('http://%s/chain' % (node))

                if response.status_code == 200:
                    length = response.json()['length']
                    chain = response.json()['chain']

                    # Check if the length is longer and the chain is valid
                    if length > max_length and self.valid_chain(chain):
                        max_length = length
                        new_chain = chain

            except Exception as e:
                print(e)

        # Replace our chain if we discovered a new, valid chain longer than ours
        if new_chain:
            self.chain = new_chain
            return True

        return False


# Instantiate the Node
app = Flask(__name__)

# Generate a globally unique address for this node
node_identifier = str(uuid4()).replace('-', '')

# Instantiate the Blockchain
blockchain = Blockchain()


@app.route('/')
def hello_world():
    return 'Hello, this is your first blockchain!'


@app.route('/mine', methods=['GET'])
def mine():
    # 给工作量证明的节点提供奖励.
    # 发送者为 "0" 表明是新挖出的币
    blockchain.new_transaction(
        sender="0",
        recipient=node_identifier,
        amount=1,
    )

    # 生成候选区块
    index = len(blockchain.chain) + 1
    timestamp = time()
    current_transactions = blockchain.current_transactions
    last_block = blockchain.last_block
    previous_hash = blockchain.hash(last_block)

    block_tmp = blockchain.new_candidate_block(index,
                                               timestamp,
                                               current_transactions,
                                               previous_hash)

    # 完成工作量证明
    proof = blockchain.proof_of_work(block_tmp)
    block_hash = blockchain.get_hash_block_proof(block_tmp, proof)

    # 生成正式区块
    block = blockchain.new_block(index, timestamp, current_transactions,
                                 previous_hash, proof)

    response = {
        'message': "New Block Forged",
        'index': block['index'],
        'hash': block_hash,
        'transactions': block['transactions'],
        'proof': block['proof'],
        'previous_hash': block['previous_hash'],
    }
    return jsonify(response), 200


@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    values = request.form

    # Create a new Transaction
    index = blockchain.new_transaction(
        values['sender'], values['recipient'], values['amount'])

    # response = {'message': f'Transaction will be added to Block {index}'}
    response = {'message': 'Transaction will be added to Block %s' % (index)}
    return jsonify(response), 201


@app.route('/chain', methods=['GET'])
def full_chain():
    response = {
        'chain': blockchain.chain,
        'length': len(blockchain.chain),
    }
    return jsonify(response), 200


@app.route('/nodes/register', methods=['POST'])
def register_nodes():
    values = request.form.to_dict()
    # if nodes is None:
    #     return "Error: Please supply a valid list of nodes", 400

    for n, ip in values.items():
        blockchain.register_node(ip)

    response = {
        'message': 'New nodes have been added',
        'total_nodes': list(blockchain.nodes),
    }
    return jsonify(response), 201


@app.route('/nodes/resolve', methods=['GET'])
def consensus():
    replaced = blockchain.resolve_conflicts()

    if replaced:
        response = {
            'message': 'Our chain was replaced',
            'new_chain': blockchain.chain
        }
    else:
        response = {
            'message': 'Our chain is authoritative',
            'chain': blockchain.chain
        }

    return jsonify(response), 200


if __name__ == '__main__':

    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('-c', '--config', default='default',
                        type=str, help='ipconfig')

    args = parser.parse_args()

    config = json.load(open('./config/' + args.config+'.json', 'r'))
    ip = config['ip']
    port = config['port']

    app.run(host=ip, port=port,debug=True)
