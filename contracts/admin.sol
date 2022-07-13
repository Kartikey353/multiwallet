// SPDX-License-Identifier:MIT;

pragma solidity ^0.8.7;

contract Admin{
    address public admin; // store address of admin
    address[] public participants; // store adress of participants or signatories 
    mapping(address=>bool) public isSignatory; // store status of their signatories position 
    uint public required;
   constructor(){
       admin=msg.sender;
   }

    modifier onlyAdmin(){    
        require(admin==msg.sender,"Only Admin can access this");
        _;
    } 

    modifier adressnotnull(address _ad){
        require(_ad!=address(0),"not valid address");
        _;
    } 


// check existence of signatory
    function checkexistenceofSignatory(address _participant) public view returns(bool){
     if(isSignatory[_participant]==true)
     return true; 
     else 
     return false;
    } 
   
// add participants
   function addParticipants(address _participant) public onlyAdmin{
         require(checkexistenceofSignatory(_participant)==false,"participant already exist");
         participants.push(_participant); 
         isSignatory[_participant]=true; 
         required=60*participants.length;
         required=required/100;
   } 

// remove owner from list
   function removeOwner(address _participant) public  onlyAdmin{
       require(checkexistenceofSignatory(_participant)==true,"participant not exist");
       isSignatory[_participant]=false; 
       for(uint i;i<participants.length;i++)
       {
           if(participants[i]==_participant){
           participants[i]=participants[participants.length-1];
           break;  
           }
       } 
       participants.pop(); 
       required=60*participants.length;
       required=required/100;
   } 

// change admin
   function changeAdmin(address _adress) public onlyAdmin{
       admin=_adress; 
   } 

// transfer partricipants ownership
   function transferrSignatory(address _from , address _destination) public  onlyAdmin adressnotnull(_from) adressnotnull(_destination){
        require(checkexistenceofSignatory(_from)==true && checkexistenceofSignatory(_destination)==false,"participant not exist"); 
        isSignatory[_destination]=true;
        isSignatory[_from]=false; 
         for(uint i;i<participants.length;i++)
       {
           if(participants[i]==_from){
           participants[i]=_destination;
           break; 
           } 
       } 
   }  

   // get all participants list
   function list_of_All_participants() public view returns(address[] memory){
       return participants;
   }

}