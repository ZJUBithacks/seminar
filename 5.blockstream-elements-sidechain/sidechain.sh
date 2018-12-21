rm -r ~/elementsdir1/elementsregtest/blocks
rm -r ~/elementsdir1/elementsregtest/chainstate
rm ~/elementsdir1/elementsregtest/wallet.dat
rm -r ~/elementsdir2/elementsregtest/blocks
rm -r ~/elementsdir2/elementsregtest/chainstate
rm ~/elementsdir2/elementsregtest/wallet.dat

FEDPEGARG="-fedpegscript=5221$(echo $PUBKEY1)21$(echo $PUBKEY2)52ae"

e1-dae $FEDPEGARG
e2-dae $FEDPEGARG
sleep 5

e1-cli generate 101
b-cli generate 101

e1-cli getpeginaddress
e1-cli getpeginaddress

ADDRS=$(e1-cli getpeginaddress)

MAINCHAIN=$(echo $ADDRS |  jq '.mainchain_address' | tr -d '"')
SIDECHAIN=$(echo $ADDRS | jq '.claim_script' | tr -d '"')

b-cli getwalletinfo

TXID=$(b-cli sendtoaddress $MAINCHAIN 1)

b-cli getwalletinfo

b-cli generate 101

b-cli getwalletinfo

PROOF=$(b-cli gettxoutproof '''["'''$TXID'''"]''')
RAW=$(b-cli getrawtransaction $TXID)

CLAIMTXID=$(e1-cli claimpegin $RAW $PROOF)

e2-cli generate 1
sleep 2

e1-cli getrawtransaction $CLAIMTXID 1

e1-cli getwalletinfo



e1-cli sendtomainchain $(b-cli getnewaddress) 10

e1-cli generate 1

e1-cli getwalletinfo

e1-cli stop
e2-cli stop
b-cli stop