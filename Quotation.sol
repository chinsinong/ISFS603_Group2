pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

import "./RFQ.sol";

contract Quotation {
    address private requester;
    address private approver;
    address private rfq;
    
    bool statusApproved = false;
    
    string[] private items;
    uint[] private quantity;
    uint[] private price;
    
    event QuotationApproved(address quotationAdr);
    
    constructor (
        address rfqVal,
        address requestVal,
        address approverVal
    ) public {
        require(requestVal != approverVal, "requester and approver cannot be same person.");
        require(RFQ(rfqVal).getStatusApproved(), "RFQ must be approved before quotation can be created.");
        
        requester = requestVal;
        approver = approverVal;
        rfq = rfqVal;

        (items, quantity) = RFQ(rfqVal).getItemInfo();
        
        price = new uint[](items.length);
    }
    
    function getInfo() public view returns(
        address requesterVal,
        address approverVal,
        address rfqVal,
        bool statusApprovedVal,
        string[] itemsVal,
        uint[] quantityVal,
        uint[] unitPriceVal
    ) {
        require(msg.sender == requester || msg.sender == approver || msg.sender == rfq, "Not authorized to information.");
        
        return(requester, approver, rfq, statusApproved, items, quantity, price);
    }
    
    function getPrice() public view returns(
        uint[] unitPriceVal
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
        emit QuotationApproved(this);
        
        RFQ(rfq).submitQuotation(requester, this);
    }
    
    function updatePrice(uint[] priceVal) public {
        require(msg.sender == requester || msg.sender == approver, "Only requester or approver can update the information.");
        require(!statusApproved, "The price cannot be updated as the quotation has been approved.");
        require(priceVal.length == price.length, "The number of unit price is different from the number of items.");
        
        for(uint i=0; i<price.length; i++) {
            price[i] = priceVal[i];
        }
    }
}