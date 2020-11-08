pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
import "./PurchaseOrder.sol";

contract DeliveryOrder {
    address private requester;
    address private supplier;
    
    address private purchaseOrder;
    
    string[] private items;
    uint[] private quantity;
    
    uint private deliveryDate;
    string private deliveryAddress;
    
    bool statusCompleted = false;
    
    event AcknowledgeDeliveryOrder(address deliveryOrderAddress);
    
    constructor(
        address requesterVal,
        address supplierVal,
        address poVal,
        string[] itemsVal,
        uint[] quantityVal,
        uint deliveryDateVal,
        string deliveryAddressVal
        
    ) public {
        requester = requesterVal;
        supplier = supplierVal;
        purchaseOrder = poVal;

        items = itemsVal;
        quantity = quantityVal;
        
        deliveryDate = deliveryDateVal;
        deliveryAddress = deliveryAddressVal;
    }
    
    function getInfo() public view returns(
        address requesterVal,
        address supplierVal,
        address poVal,
        string[] itemsVal,
        uint[] quantityVal,
        uint deliveryDateVal,
        string deliveryAddressVal,
        bool statusCompletedVal
    ) {
        require(msg.sender == requester || msg.sender == supplier, "Not authorized to information.");
        
        return(requester, supplier, purchaseOrder, items, quantity, deliveryDate, deliveryAddress, statusCompleted);
    }
    
    function acknowledgeDeliveryOrder() public {
        require(msg.sender == requester, "The delivery order can only be acknowledged by the requester.");
        require(!statusCompleted, "The delivery order has already been acknowledged.");
        
        statusCompleted = true;
        
        emit AcknowledgeDeliveryOrder(this);
        
        PurchaseOrder(purchaseOrder).setStatusCompleted();
    }
}