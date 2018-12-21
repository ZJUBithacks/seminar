
e1-cli generate 1
sleep 2

ADDR1=$(e1-cli getnewaddress)
ADDR2=$(e2-cli getnewaddress)

VALID1=$(e1-cli validateaddress $ADDR1)
PUBKEY1=$(echo $VALID1 | jq '.pubkey' | tr -d '"')

VALID2=$(e2-cli validateaddress $ADDR2)
PUBKEY2=$(echo $VALID2 | jq '.pubkey' | tr -d '"')

KEY1=$(e1-cli dumpprivkey $ADDR1)
KEY2=$(e2-cli dumpprivkey $ADDR2)

MULTISIG=$(e1-cli createmultisig 2 '''["'''$PUBKEY1'''", "'''$PUBKEY2'''"]''')
REDEEMSCRIPT=$(echo $MULTISIG | jq '.redeemScript' | tr -d '"')
echo $REDEEMSCRIPT

e1-cli stop
e2-cli stop
sleep 5

SIGNBLOCKARG="-signblockscript=$(echo $REDEEMSCRIPT)"

rm -r ~/elementsdir1/elementsregtest/blocks
rm -r ~/elementsdir1/elementsregtest/chainstate
rm ~/elementsdir1/elementsregtest/wallet.dat
rm -r ~/elementsdir2/elementsregtest/blocks
rm -r ~/elementsdir2/elementsregtest/chainstate
rm ~/elementsdir2/elementsregtest/wallet.dat

e1-dae $SIGNBLOCKARG
e2-dae $SIGNBLOCKARG

sleep 5

e1-cli importprivkey $KEY1
e2-cli importprivkey $KEY2

echo "This will error - that is ok:"
e1-cli generate 1
e2-cli generate 1

HEX=$(e1-cli getnewblockhex)

e1-cli getblockcount
 
e1-cli submitblock $HEX

e1-cli getblockcount

SIGN1=$(e1-cli signblock $HEX)
SIGN2=$(e2-cli signblock $HEX)

COMBINED=$(e1-cli combineblocksigs $HEX '''["'''$SIGN1'''", "'''$SIGN2'''"]''')

COMPLETE=$(echo $COMBINED | jq '.complete' | tr -d '"')

SIGNEDBLOCK=$(echo $COMBINED | jq '.hex' | tr -d '"')

echo $COMPLETE

e2-cli submitblock $SIGNEDBLOCK

e1-cli getblockcount
e2-cli getblockcount

e1-cli stop
e2-cli stop
sleep 5
