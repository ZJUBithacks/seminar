
e1-cli getwalletinfo

e1-cli getwalletinfo bitcoin

e1-cli dumpassetlabels

e1-cli getwalletinfo $(e1-cli dumpassetlabels | jq '.bitcoin' | tr -d '"')

ISSUE=$(e1-cli issueasset 100 1)

ASSET=$(echo $ISSUE | jq '.asset' | tr -d '"')
TOKEN=$(echo $ISSUE | jq '.token' | tr -d '"')
ITXID=$(echo $ISSUE | jq '.txid' | tr -d '"')
IVIN=$(echo $ISSUE | jq '.vin' | tr -d '"')

echo $ASSET

e1-cli listissuances

e1-cli stop
sleep 2
e1-dae -assetdir=$ASSET:demoasset
sleep 2
e1-cli listissuances

e1-cli generate 1

sleep 2
e2-cli listissuances

IADDR=$(e1-cli gettransaction $ITXID | jq '.details[0].address' | tr -d '"')

e2-cli importaddress $IADDR

e2-cli listissuances

ISSUEKEY=$(e1-cli dumpissuanceblindingkey $ITXID $IVIN)

e2-cli importissuanceblindingkey $ITXID $IVIN $ISSUEKEY

e2-cli listissuances

E2DEMOADD=$(e2-cli getnewaddress)
e1-cli sendtoaddress $E2DEMOADD 10 "" "" false demoasset
sleep 2
e1-cli generate 1
sleep 2

e2-cli getwalletinfo
e1-cli getwalletinfo

E1DEMOADD=$(e1-cli getnewaddress)
e2-cli sendtoaddress $E1DEMOADD 10 "" "" false $ASSET
sleep 2
e2-cli generate 1
sleep 2
e1-cli getwalletinfo
e2-cli getwalletinfo

RTRANS=$(e1-cli reissueasset $ASSET 99)
RTXID=$(echo $RTRANS | jq '.txid' | tr -d '"')

e1-cli listissuances $ASSET

e1-cli gettransaction $RTXID

e1-cli generate 1
sleep 2
RAWRTRANS=$(e2-cli getrawtransaction $RTXID)
e2-cli decoderawtransaction $RAWRTRANS

e1-cli getwalletinfo
e2-cli getwalletinfo

echo "This will error and that is expected:"
e2-cli reissueasset $ASSET 10

RITRECADD=$(e2-cli getnewaddress)
e1-cli sendtoaddress $RITRECADD 1 "" "" false $TOKEN
e1-cli generate 1
sleep 2
e1-cli getwalletinfo
e2-cli getwalletinfo

RISSUE=$(e2-cli reissueasset $ASSET 10)
e2-cli getwalletinfo

e2-cli generate 1
sleep 2

e1-cli listissuances

RITXID=$(echo $RISSUE | jq '.txid' | tr -d '"')
RIADDR=$(e2-cli gettransaction $RITXID | jq '.details[0].address' | tr -d '"')

e1-cli importaddress $RIADDR
e1-cli listissuances

UBRISSUE=$(e2-cli issueasset 55 1 false)

UBASSET=$(echo $UBRISSUE | jq '.asset' | tr -d '"')

e2-cli getwalletinfo

e2-cli generate 1
sleep 2
UBRITXID=$(echo $UBRISSUE | jq '.txid' | tr -d '"')

UBRIADDR=$(e2-cli gettransaction $UBRITXID | jq '.details[0].address' | tr -d '"')

e1-cli importaddress $UBRIADDR

e1-cli listissuances

e2-cli destroyamount $UBASSET 5
e2-cli getwalletinfo
