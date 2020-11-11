pragma solidity ^0.4.25;
//pragma experimental ABIEncoderV2;

import "./RFQ.sol";

contract Quotation {
    address private requester;
    address private approver;
    address private rfq;
    
    bool statusApproved = false;
    
    bytes[10] private items;
    uint[10] private quantity;
    uint[10] private price;
    
    event StatusChanged(string eventType, address addr);
    
    constructor (
        address rfqVal,
        address requestVal,
        address approverVal,
        bytes itemVal,
        uint[10] quantityVal
    ) public {
        require(requestVal != approverVal, "requester and approver cannot be same person.");
        require(RFQ(rfqVal).getStatusApproved(), "RFQ must be approved before quotation can be created.");

        requester = requestVal;
        approver = approverVal;
        rfq = rfqVal;

        //bytes memory itemVal = RFQ(rfqVal).getItems();
        uint j = 0;
        string memory itemVal2="";
        
        for(uint i; i<itemVal.length; i++) {
            if(keccak256(abi.encodePacked(itemVal[i])) == keccak256(abi.encodePacked(";"))) {
                items[j] = bytes(itemVal2);
                j++;
                itemVal2 = "";
            }
            else {
                itemVal2 = string(abi.encodePacked(itemVal2,itemVal[i]));
                
                if(i == itemVal.length - 1) {
                    items[j] = bytes(itemVal2);
                }
            }
        }
        
        //quantity = RFQ(rfqVal).getQuantity();
        quantity = quantityVal;
        
        emit StatusChanged("Quotation is created.", address(this));
    }
    
    function getInfo() public view returns(
        address requesterVal,
        address approverVal,
        address rfqVal,
        bool statusApprovedVal,
        string itemsVal,
        uint[10] quantityVal,
        uint[10] unitPriceVal
    ) {
        
        string memory itemVal2="";
        
        for(uint i=0;i<10;i++) {
            itemVal2 = string(abi.encodePacked(itemVal2,";",items[i]));
        }
        
        return(requester, approver, rfq, statusApproved, itemVal2, quantity, price);
    }
    
    function getPrice() public view returns(
        uint[10] unitPriceVal
    ) {
        require(msg.sender == requester || msg.sender == approver || msg.sender == rfq, "Not authorized to information.");

        return (price);
    }
    
    function getStatusApproved() public view returns (
        bool statusApprovedVal
    ) {
        require(msg.sender == requester || msg.sender == approver || msg.sender == rfq, "Not authorized to information.");
        return (statusApproved);
    }
    
    function approveQuotation() public {
        require(statusApproved == false, "Quotation is already approved.");
        require(msg.sender == approver, "Only approver can approve the quotation");
        
        statusApproved = true;
        emit StatusChanged("Quotation is approved.", address(this));
        
        RFQ(rfq).submitQuotation(requester, address(this));
    }
    
    function updatePrice(uint[] priceVal) public {
        require(msg.sender == requester || msg.sender == approver, "Only requester or approver can update the information.");
        require(!statusApproved, "The price cannot be updated as the quotation has been approved.");
        //require(priceVal.length == price.length, "The number of unit price is different from the number of items.");
        
        for(uint i=0; i<price.length; i++) {
            if(quantity[i] > 0) {
                price[i] = priceVal[i];
            }
        }
    }
}