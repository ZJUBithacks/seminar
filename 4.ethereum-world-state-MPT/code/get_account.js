var Trie = require('merkle-patricia-tree/secure');
var levelup = require('levelup');
var leveldown = require('leveldown');
var RLP = require('rlp');
var assert = require('assert');
var utils = require('ethereumjs-util')
var BN = utils.BN;
var Account = require('ethereumjs-account');
var argv = require('yargs')
	.demand(['root', 'address'])
	.argv;

// connecting to the leveldb database
var db = levelup(leveldown('./data/geth/chaindata'));

// adding the "stateRoot" value from the block so that we can inspect the state root at that block height.
var stateRoot = String(argv.root);
// the account to query
var address = String(argv.address);

// creating a trie object of the merkle-patricia-tree library
var trie = new Trie(db, stateRoot);

trie.get(address, function (err, raw) {
	if(err){
		console.log(err);
		return;
	}

	console.log(`\nAccount ${address}:`);
	var account = new Account(raw);
	//console.log(account);
	console.log('nonce:', new BN(account.nonce));
	console.log('balance:', new BN(account.balance));
	console.log('storageRoot:', new BN(account.storageRoot));
	console.log('codeHash:', new BN(account.codeHash));
});
