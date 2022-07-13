// SPDX-License-Identifier:MIT;

pragma solidity ^0.8.7;

import "contracts/admin.sol";

contract main is Admin{
event Deposit(address indexed sender, uint amount);
event Submit(uint indexed txId);
event Approve(address indexed owner,uint indexed txId);
event Revoke(address indexed owner ,uint indexed txId);
event Execute(uint indexed txId);


struct Transaction{
    address to;
    uint value;
    bytes data;
    bool executed;
} 

modifier onlyOwner(){
    require(isSignatory[msg.sender]==true,"only owner can access to this");
    _;
} 

modifier txExist(uint _txId){
require(_txId<transactions.length,"transaction id does not exist");
_;
} 


modifier notApproved(uint _txId){
    require(!approved[_txId][msg.sender],"tx already approved");
    _;
}

modifier notExecuted(uint _txId){
    require(transactions[_txId].executed,"transaction is already executed");
    _;
}




Transaction[] public transactions; 
mapping(uint => mapping(address => bool)) public approved;
constructor(){
    require(participants.length>0,"admin have to approved at least one participant");
}


receive() external payable{
    emit Deposit(msg.sender,msg.value);
}

function submit(address _to ,uint _value, bytes calldata _data) external onlyOwner{
transactions.push(Transaction({
    to:_to,
    value:_value,
    data:_data,
    executed:false
})); 
emit Submit(transactions.length-1);
}

function approve(uint _txId) external onlyOwner txExist(_txId) notApproved(_txId) notExecuted(_txId){
approved[_txId][msg.sender]=true;
emit Approve(msg.sender,_txId);
} 


function countOfapproved(uint _txid) private view returns(uint count){
    for(uint i;i<participants.length;i++)
    {
        if(approved[_txid][participants[i]]){
             count+=1;
        }
    }
} 


function execute(uint _txId) external txExist(_txId) notExecuted(_txId){
    require(countOfapproved(_txId)>=required,"you have not require amount of approval"); 
    Transaction storage transaction=transactions[_txId];
    
    transaction.executed=true;
   (bool success, )=transaction.to.call{value:transaction.value}(
        transaction.data
   ); 

   require(success,"tx failed");
} 

function revoke(uint _txId) external onlyOwner txExist(_txId) notApproved(_txId) notExecuted(_txId) {
 approved[_txId][msg.sender]=false; 
 emit Revoke(msg.sender,_txId);
}
}