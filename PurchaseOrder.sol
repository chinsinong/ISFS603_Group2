pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
import "./RFQ.sol";
import "./Quotation.sol";
import "./DeliveryOrder.sol";

contract PurchaseOrder {
    address private requester;
    address private approver;
    address private supplier;
    
    address private rfq;
    address private quotation;
    address private deliveryOrder;
    
    string[] private items;

    uint[] private quantity;
    
    uint[] private price;
    
    bool statusCompleted=false;
    bool statusPaid=false;
    
    event DeliveryOrderCreated(address deliveryOrderAddr);
    event PurchaseOrderCompleted(address purchaseOrderAddr);
    event PurchaseOrderPaid(address purchaseOrderAddr);
    
    constructor(
        address requesterVal,
        address approverVal,
        address supplierVal,
        address rfqVal,
        address quotationVal,
        string[] itemsVal,
        uint[] quantityVal,
        uint[] priceVal
    ) public {
        requester = requesterVal;
        approver = approverVal;
        supplier = supplierVal;
        rfq = rfqVal;
        quotation = quotationVal;
        
        items = itemsVal;
        quantity = quantityVal;
        price = priceVal;
    }
    
    function getInfo() public view returns(
        address requestorVal,
        address approverVal,
        address supplierVal,
        address rfqVal,
        address quotationVal,
        address deliveryOrderVal,
        
        string[] itemsVal,
        uint[] quantityVal,
        uint[] unitPriceVal,
        
        bool statusCompletedVal,
        bool statusPaidVal
    ) {
        require(msg.sender == requester || msg.sender == approver || msg.sender == supplier, "Not authorized to information.");
        
        return(requester, approver, supplier, rfq, quotation, deliveryOrder, items, quantity, price, statusCompleted, statusPaid);
    }
    
    function createDeliveryOrder(
        uint deliveryDateVal,
        string deliverAddressVal
    ) public {
        require(msg.sender == supplier, "The delivery order can only be created by supplier.");
        
        DeliveryOrder dOrder = new DeliveryOrder(requester, supplier, address(this), items, quantity, deliveryDateVal, deliverAddressVal);
        
        deliveryOrder = address(dOrder);
        
        emit DeliveryOrderCreated(dOrder);
    }
    
    function setStatusCompleted() public {
        require(msg.sender == requester || msg.sender == approver || msg.sender == supplier || msg.sender == deliveryOrder, "Not authorized to update information.");
        require(!statusCompleted, "The purchase order is already completed.");

        statusCompleted = true;
        emit PurchaseOrderCompleted(this);
    }
    
    function setStatusPaid() public {
        require(msg.sender == requester || msg.sender == approver || msg.sender == supplier || msg.sender == deliveryOrder, "Not authorized to update information.");
        require(!statusPaid, "The purchase order is already paid.");
        
        statusPaid = true;
        emit PurchaseOrderPaid(this);
    }
}