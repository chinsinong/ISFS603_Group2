pragma solidity ^0.4.25;
//pragma experimental ABIEncoderV2;
import "./PurchaseOrder.sol";

contract DeliveryOrder {
    // address private requester;
    // address private supplier;
    
    // address private purchaseOrder;

    // bytes[10] private items;
    // uint[10] private quantity;
    
    // uint private deliveryDate;
    // string private deliveryAddress;
    
    // bool statusCompleted = false;
    
    // event StatusChanged(string eventName, address addr);
    
    // constructor(
    //     address requesterVal,
    //     address supplierVal,
    //     address poVal,
    //     bytes itemVal,
    //     uint[10] quantityVal,
    //     uint deliveryDateVal,
    //     string deliveryAddressVal
        
    // ) public {
    //     requester = requesterVal;
    //     supplier = supplierVal;
    //     purchaseOrder = poVal;

    //     //items = itemsVal;
    //     //bytes memory itemVal = RFQ(rfqVal).getItems();
    //     uint j = 0;
    //     string memory itemVal2="";
        
    //     for(uint i; i<itemVal.length; i++) {
    //         if(keccak256(abi.encodePacked(itemVal[i])) == keccak256(abi.encodePacked(";"))) {
    //             items[j] = bytes(itemVal2);
    //             j++;
    //             itemVal2 = "";
    //         }
    //         else {
    //             itemVal2 = string(abi.encodePacked(itemVal2,itemVal[i]));
                
    //             if(i == itemVal.length - 1) {
    //                 items[j] = bytes(itemVal2);
    //             }
    //         }
    //     }
        
    //     quantity = quantityVal;
        
    //     deliveryDate = deliveryDateVal;
    //     deliveryAddress = deliveryAddressVal;
    //     emit StatusChanged("Delivery order is created", address(this));
    // }
    
    // function getInfo() public view returns(
    //     address requesterVal,
    //     address supplierVal,
    //     address poVal,
    //     string itemsVal,
    //     uint[10] memory quantityVal,
    //     uint deliveryDateVal,
    //     string deliveryAddressVal,
    //     bool statusCompletedVal
        
    // ) {
    //     require(msg.sender == requester || msg.sender == supplier, "Not authorized to information.");
        
    //     string memory itemVal2="";
        
    //     for(uint i=0;i<10;i++) {
    //         itemVal2 = string(abi.encodePacked(itemVal2,";",items[i]));
    //     }
        
    //     // return(requester, supplier, purchaseOrder, items, quantity, deliveryDate, deliveryAddress, statusCompleted);
    //     return(requester, supplier, purchaseOrder, itemVal2, quantity, deliveryDate, deliveryAddress, statusCompleted);
    // }
    
    // function acknowledgeDeliveryOrder() public {
    //     require(msg.sender == requester, "The delivery order can only be acknowledged by the requester.");
    //     require(!statusCompleted, "The delivery order has already been acknowledged.");
        
    //     statusCompleted = true;
        
    //     emit StatusChanged("Acknowledge Delivery Order", address(this));
        
    //     PurchaseOrder(purchaseOrder).setStatusCompleted();
    // }
}