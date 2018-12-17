pragma solidity ^0.4.0;

contract Demo {
    uint a;
	address owner;
	
	// constructor
	function Demo() {
		owner = msg.sender;
		a = 10;
	}

	// get 
    function setA(uint x) {
        a = x;
    }

	// set
    function getA() constant returns (uint) {
        return a;
    }

	// destructor
	function kill() {
		if(owner == msg.sender){
			selfdestruct(owner);
		}
	}
}
