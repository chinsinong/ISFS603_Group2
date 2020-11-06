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

    mapping(string => uint) quantity;

    
    bool private statusApproved = false;
    
    bool private statusPOIssued = false;
    
    event StatusChanged(uint256 id, bool latestStatus);
    
    constructor (
        
        address requestorVal,
        address approverVal
        
    ) public {
        require(requestorVal != approverVal, "Requestor and approver cannot be same person.");
        
        requestor = requestorVal;
        approver = approverVal;
    }
    
    function getInfo() public view returns (
        address requestorVal,
        address approverVal,
        address[] supplierVal,
        string[] itemVal,
        uint[] quantityVal
    ) {
        
        uint[] memory qty = new uint[](item.length);
        
        for(uint i=0; i < item.length; i++) {
            qty[i] = quantity[item[i]];
        }
        
        return (requestor, approver, supplier, item, qty);
    }
    
    
    function approveRFQ() public {
        require(statusApproved == false, "RFQ is already approved.");
        require(msg.sender == approver, "Only approver can approve the RFQ");
        statusApproved = true;
    }
    
    function additem(string itemVal, uint quantityVal) public {
        require(statusApproved == false, "No item can be added after RFQ is approved.");
        require(msg.sender == requestor || msg.sender == approver, "Only requestor or approver can add product.");
        
        
        if(quantity[itemVal] == 0) {
            item.push(itemVal);
        }
        quantity[itemVal] += quantityVal;
    }
    
    function removeitem(string itemVal, uint quantityVal) public {
        require(statusApproved == false, "No item can be removed after RFQ is approved.");
        require(msg.sender == requestor || msg.sender == approver, "Only requestor or approver can remove product.");
        require(quantity[itemVal] > 0 , "Item does not exist in RFQ.");
        require(quantityVal <= quantity[itemVal], "Quantity must be less than existing quantity.");

        if(quantityVal == quantity[itemVal]) {
            for(uint i=0; i < item.length; i++) {
                
                if(keccak256(bytes(itemVal)) == keccak256(bytes(item[i]))) {
                    
                    for(uint j=i; j < item.length - 1; j++) {
                        item[j] = item[j+1];
                    }
                    delete item[item.length - 1];
                    item.length--;
                    break;
                }
            }
        }
        
        quantity[itemVal] -= quantityVal;
    }
    
}