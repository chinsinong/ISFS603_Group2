pragma solidity ^0.4.25;

contract RFQ {
    address private requestor;
    
    address private approver;
    
    address private supplier;
    
    string[] private item;
    
    uint16[] private quantity;
    
    ufixed[] private price;
    
    string private status;
    
    
    constructor (
        address requestorVal
    ) public {
        
    }
    
    function getInfo() public view returns (
        address requestorVal
    ) {
        return (requestor);
    }
    
}