var Web3 = require('web3');
var solc = require('solc');
var fs = require('fs');
var argv = require('yargs')
	.boolean(['deploy'])
	.boolean(['get'])
	.default({'set': undefined})
	.default({'addr': '0xA26663D3e4dea618CEaCCc85E4662f30a8df5167'})
	.argv;

var source = fs.readFileSync('./store.sol', 'utf8');
var compiled = solc.compile(source);

var bytecode = compiled.contracts[':SimpleStorage'].bytecode;
var abi = JSON.parse(compiled.contracts[':SimpleStorage'].interface);

const account = '0x7dfda809012fb00ba9535105c4ac8043c85adf9f';

var web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));

if(argv.deploy == true) {
	var myContract = new web3.eth.Contract(abi);

	myContract.deploy({
		data: '0x' + bytecode,
	}).send({
		from: account,
		gas: 4000000,
		gasPrice: '30000000000000',
	}).then((instance) => {
		console.log('address:', instance.options.address);
	})
}

if(argv.get == true) {
	var contractInstance = new web3.eth.Contract(abi, String(argv.addr));
	contractInstance.methods.get().call().then(ret => {
		console.log('Number:', ret);
	})
}

if(argv.set != undefined) {
	console.log(argv.set);
	var contractInstance = new web3.eth.Contract(abi, String(argv.addr));
	const options = {
		from: account,
		gas: 4000000,
		gasPrice: '3000000000000',
	};

	var number = web3.utils.toHex(Number(argv.set));

	contractInstance.methods.set(number).send(options, (err, hash) => {
		if(err){
			console.log(err);
			return;
		}
		console.log('txHash:', hash);
	}).then(ret => {
		console.log(ret);
	})
}
