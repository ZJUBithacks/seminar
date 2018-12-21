
e1-cli sendtoaddress $(e1-cli getnewaddress) 21000000 "" "" true
e1-cli generate 101
sleep 5
e1-cli sendtoaddress $(e2-cli getnewaddress) 10500000 "" "" false
e1-cli generate 101
sleep 5

e1-cli getwalletinfo
e2-cli getwalletinfo

ADDR=$(e2-cli getnewaddress)

echo $ADDR

e2-cli validateaddress $ADDR

TXID=$(e2-cli sendtoaddress $ADDR 1)

sleep 2

e1-cli getrawmempool
e2-cli getrawmempool
e1-cli getinfo
e2-cli getinfo

e2-cli generate 1
sleep 2

e1-cli getrawmempool
e2-cli getrawmempool
e1-cli getinfo
e2-cli getinfo

e2-cli gettransaction $TXID

echo "This may error - that is ok"
e1-cli gettransaction $TXID

e1-cli getrawtransaction $TXID 1

e1-cli importprivkey $(e2-cli dumpprivkey $ADDR)

e1-cli gettransaction $TXID

e1-cli getwalletinfo

e1-cli listunspent 1 1

e1-cli importblindingkey $ADDR $(e2-cli dumpblindingkey $ADDR)

e1-cli getwalletinfo
e1-cli listunspent 1 1
e1-cli gettransaction $TXID