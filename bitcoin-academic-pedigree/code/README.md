# Leaning and Building Blockchain using Python

```
## running a mining node on port 5000
$ python pow.py
## 查看初始区块链
$ python script.py -m chain
or
$ http://localhost:5000/chain

## 发送交易
$ python script.py -m send
or
$ curl -X POST -H "Content-Type: application/json" -d '{
 "sender": "someone-address",
 "recipient": "someone-other-address",
 "amount": 5
}' "http://localhost:5000/transactions/new"

## 挖矿打包交易
$ python script.py -m mine
or
$ http://localhost:5000/mine

## 浏览区块链中的区块，看交易是否被打包进新的区块
$ python script.py -m chain

## 看block3的previous_hash是否以4个0开头
$ python script.py -m send
$ python script.py -m mine
$ python script.py -m chain

--------------------------------------------
### 多个节点同步区块数据
## 运行新挖矿节点5001`
$ python pow.py -c config
$ python script.py -m chain -c config  此时未同步5001的数据

## 将5000链的信息告知5001
$ python script.py -m register -c config
or
$ curl -X POST -H "Content-Type: application/json" -d '{ "nodes": ["http://localhost:5000"]}' "http://localhost:5001/nodes/register"

## 同步区块数据
$ python script.py -m resolve -c config
$ python script.py -m chain -c config

```
