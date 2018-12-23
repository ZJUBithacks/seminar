cd
cd elements
cd src

shopt -s expand_aliases

alias b-dae="bitcoind -datadir=$HOME/bitcoindir"
alias b-cli="bitcoin-cli -datadir=$HOME/bitcoindir"

alias e1-dae="$HOME/elements/src/elementsd -datadir=$HOME/elementsdir1"
alias e1-cli="$HOME/elements/src/elements-cli -datadir=$HOME/elementsdir1"

alias e2-dae="$HOME/elements/src/elementsd -datadir=$HOME/elementsdir2"
alias e2-cli="$HOME/elements/src/elements-cli -datadir=$HOME/elementsdir2"

echo "The following 3 lines may error - that is fine."

b-cli stop
e1-cli stop
e2-cli stop
sleep 5

cd

echo "The following 3 'rm' commands may error - that is fine."

rm -r ~/bitcoindir ; rm -r ~/elementsdir1 ; rm -r ~/elementsdir2
mkdir ~/bitcoindir ; mkdir ~/elementsdir1 ; mkdir ~/elementsdir2

cd elements
cd src

cp ~/elements/contrib/assets_tutorial/bitcoin.conf ~/bitcoindir/bitcoin.conf
cp ~/elements/contrib/assets_tutorial/elements1.conf ~/elementsdir1/elements.conf
cp ~/elements/contrib/assets_tutorial/elements2.conf ~/elementsdir2/elements.conf

b-dae

sleep 5

b-cli -getinfo

e1-dae
e2-dae

sleep 5

e1-cli getwalletinfo
e2-cli getwalletinfo
