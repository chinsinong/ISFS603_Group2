pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

contract RFQ {
    address private requestor;
    
    address private approver;
    
    address[] private supplier;
    
    address[] private quotation;
    
    address private selectedSupplier;
    
    address private selectedQuotation;
    
    string[] private item;
    
    uint16[] private quantity;
    
    bool private statusApproved = false;
    
    bool private statusPOIssued = false;
    
    event StatusChanged(uint256 id, bool latestStatus);
    
    constructor (
        
        address requestorVal
        
    ) public {
        
        require(tx.origin == requestorVal, "Only requestor can create RFQ.");
        
        requestor = requestorVal;
        
    }
    
    function getInfo() public view returns (
        address requestorVal,
        address approverVal,
        address[] supplierVal,
        string[] itemVal,
        uint16[] quantityVal
    ) {
        return (requestor, approver, supplier, item, quantity);
    }
    
    function setApprover(address approverVal) public {
        require(requestor != approverVal, "Requestor cannot be approver");
        approver = approverVal;
    }
    
    function setStatusApprove(bool approverVal) public {
        require(msg.sender == approver, "Only approver can approve the RFQ");
        statusApproved = true;
    }
    
    function addProduct(string itemVal, uint16 quantityVal) public {
        require(statusApproved == false, "No item can be added after RFQ is approved.");
        require(msg.sender == requestor, "Only requestor can add product.");
        
        item.push(itemVal);
        quantity.push(quantityVal);
    }
    
    
    
}