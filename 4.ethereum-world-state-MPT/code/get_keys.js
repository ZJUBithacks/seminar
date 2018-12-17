var Trie = require('merkle-patricia-tree/secure');
var levelup = require('levelup');
var leveldown = require('leveldown');
var RLP = require('rlp');
var assert = require('assert');
var argv = require('yargs')
	.demand(['root'])
	.argv;

var utils = require('ethereumjs-util')
var BN = utils.BN;

var Account = require('ethereumjs-account');

//Connecting to the leveldb database
var db = levelup(leveldown('./data/geth/chaindata'));

//Adding the "stateRoot" value from the block so that we can inspect the state root at that block height.
var root = argv.root;

//Creating a trie object of the merkle-patricia-tree library
var trie = new Trie(db, root);

//Creating a nodejs stream object so that we can access the data
var stream = trie.createReadStream()

//Turning on the stream (because the node js stream is set to pause by default)
stream.on('data', function (data){
  //printing out the keys of the "state trie"
  console.log(data.key);
});

