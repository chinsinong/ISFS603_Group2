pragma solidity ^0.4.25;
//pragma experimental ABIEncoderV2;
// import "./RFQ.sol";
// import "./Quotation.sol";
import "./DeliveryOrder.sol";

contract PurchaseOrder {
    address private requester;
    address private approver;
    address private supplier;
    
    address private rfq;
    address private quotation;
    address private deliveryOrder;
    
    bytes[10] private items;
    uint[10] private quantity;
    uint[10] private price;
    
    bool statusCompleted=false;
    bool statusPaid=false;
    
    event StatusChanged(string eventType, address addr);
    
    // event DeliveryOrderCreated(address deliveryOrderAddr);
    // event PurchaseOrderCompleted(address purchaseOrderAddr);
    // event PurchaseOrderPaid(address purchaseOrderAddr);
    
    constructor(
        address requesterVal,
        address approverVal,
        address supplierVal,
        address rfqVal,
        address quotationVal,
        bytes itemVal,
        uint[10] quantityVal,
        uint[10] priceVal
    ) public {
        require(requesterVal != approverVal, "requester and approver cannot be same person.");
        //require(RFQ(rfqVal).getStatusApproved(), "RFQ must be approved before quotation can be created.");
        
        requester = requesterVal;
        approver = approverVal;
        supplier = supplierVal;
        rfq = rfqVal;
        quotation = quotationVal;
        
        // items = itemsVal;
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
        
        quantity = quantityVal;
        price = priceVal;
        
        emit StatusChanged("Purchase order is created.", address(this));
    }
    
    function getInfo() public view returns(
        address requestorVal,
        address approverVal,
        address supplierVal,
        address rfqVal,
        address quotationVal,
        address deliveryOrderVal,
        
        string itemVal,
        uint[10] quantityVal,
        uint[10] unitPriceVal,
        
        bool statusCompletedVal,
        bool statusPaidVal
    ) {
        require(msg.sender == requester || msg.sender == approver || msg.sender == supplier, "Not authorized to information.");
        
        string memory itemVal2="";
        
        for(uint i=0;i<10;i++) {
            itemVal2 = string(abi.encodePacked(itemVal2,";",items[i]));
        }
        
        return(requester, approver, supplier, rfq, quotation, deliveryOrder, itemVal2, quantity, price, statusCompleted, statusPaid);
    }
    
    // function createDeliveryOrder(
    //     uint deliveryDateVal,
    //     string deliverAddressVal
    // ) public {
    //     require(msg.sender == supplier, "The delivery order can only be created by supplier.");
        
    //     string memory itemVal2="";
    //     for(uint i=0;i<10;i++) {
    //         itemVal2 = string(abi.encodePacked(itemVal2, ";", items[i]));
    //     }
        
    //     DeliveryOrder dOrder = new DeliveryOrder(requester, supplier, address(this), bytes(itemVal2), quantity, deliveryDateVal, deliverAddressVal);
        
    //     deliveryOrder = address(dOrder);

    // }
    
    // function setStatusCompleted() public {
    //     require(msg.sender == requester || msg.sender == approver || msg.sender == supplier || msg.sender == deliveryOrder, "Not authorized to update information.");
    //     require(!statusCompleted, "The purchase order is already completed.");

    //     statusCompleted = true;
    //     emit StatusChanged("Purchase order is completed", address(this));
    // }
    
    // function setStatusPaid() public {
    //     require(msg.sender == requester || msg.sender == approver || msg.sender == supplier || msg.sender == deliveryOrder, "Not authorized to update information.");
    //     require(!statusPaid, "The purchase order is already paid.");
        
    //     statusPaid = true;
    //     emit StatusChanged("Purchase order is paid", address(this));
    // }
}