pragma solidity ^0.4.25;
//pragma experimental ABIEncoderV2;

import "./Quotation.sol";
import "./PurchaseOrder.sol";

contract RFQ {

    address private requester;
    address private approver;
    
    uint itemCount=0;
    bytes[10] private items;

    mapping(string => uint) private itemsMap;
    mapping(string => uint) private quantity;
    
    bool private statusApproved = false;
    bool private statusPOIssued = false;
    
    address[] private suppliers;
    mapping(address => bool) private suppliersList;
    mapping(address => address) private quotations;
    address private selectedSupplier;
    
    address private purchaseOrder;
    
    event StatusChanged(string eventType, address addr);
    // event RFQApproved(address rfqAddr);
    // event QuotationCreated(address quotationAddr);
    // event QuotationSubmitted(address quotationAddr);
    // event QuotationRemoved(address quotationAddr);
    // event QuotationConfirmed(address quotationAddr);
    // event PurchaseOrderCreated(address purchaseOrderAddr);
    
    constructor(
        address requesterVal,
        address approverVal
        
    ) public {
        require(requesterVal != approverVal, "Requester and approver cannot be same person.");
        
        requester = requesterVal;
        approver = approverVal;
    }
    
    function getInfo() public view returns(
        address requesterVal,
        address approverVal,
        bool statusApprovedVal,
        bool statusPOIssuedVal,
        string itemVal,
        uint[10] quantityVal,
        address[] suppliersVal,
        address[] quotationsVal
    ) 
    {
        string memory itemVal2="";
        uint[10] memory quantityVal2;
        
        for(uint i=0;i<itemCount;i++) {
            itemVal2 = string(abi.encodePacked(itemVal2,";",items[i]));
            quantityVal2[i] = quantity[string(items[i])];
        }
        
        address[] memory suppliersVal2 = new address[](suppliers.length);
        address[] memory quotationsVal2 = new address[](suppliers.length);
        //address selectedSupplierVal2;
        
        if(msg.sender == requester || msg.sender == approver) {
            // returns all suppliers and quotations information if function called by requester or approver
            suppliersVal2 = suppliers;
            
            for(uint j=0; j < suppliers.length; j++) {
                quotationsVal2[j] = quotations[suppliers[j]];
            }
            
            // selectedSupplierVal2 = selectedSupplier;
            
        } else if(suppliersList[msg.sender]) {
            // returns supplier specific information if function called by supplier
            
            suppliersVal2 = new address[](1);
            suppliersVal2[0] = msg.sender;
            
            quotationsVal2 = new address[](1);
            quotationsVal2[0] = quotations[msg.sender];
            
            // selectedSupplierVal2 = selectedSupplier;
        }
        
        //return (requester,approver, statusApproved, statusPOIssued, itemVal2, quantityVal2);
        return (requester,approver, statusApproved, statusPOIssued, itemVal2, quantityVal2, suppliersVal2, quotationsVal2);
    }
    
    function getItems() public view returns(
        bytes value
    ) {
        
        string memory itemVal2="";
        for(uint i=0;i<itemCount;i++) {
            itemVal2 = string(abi.encodePacked(itemVal2, ";", items[i]));
        }
        
        return (bytes(itemVal2));
    }
    
    function getQuantity() public view returns(
        uint[10] value
    ) {
        uint[10] memory quantityVal2;
        
        for(uint i=0;i<itemCount;i++) {
            quantityVal2[i] = quantity[string(items[i])];
        }
        
        return (quantityVal2);
    }
    
    
    // function getInfo() public view returns (
    //     address requesterVal
    //     address approverVal
    //     //string itemsVal,
    //     //uint[] quantityVal,
    //     // bool statusApprovedVal,
    //     // bool statusPOIssuedVal
    //     // string suppliersVal,
    //     // string quotationsVal,
    //     // address selectedSupplierVal
    // ) {
        
    //     string memory itemsVal2 = string(abi.encodePacked(items));
        

    //     // convert mapping to array
    //     // uint[] memory quantityVal2 = new uint[](items.length);
        
    //     // for(uint i=0; i < items.length; i++) {
    //     //     quantityVal2[i] = quantity[items[i]];
    //     // }

    //     // address[] memory suppliersVal2 = new address[](suppliers.length);
    //     // address[] memory quotationsVal2 = new address[](suppliers.length);
    //     // address selectedSupplierVal2;
        
    //     // if(msg.sender == requester || msg.sender == approver) {
    //     //     // returns all suppliers and quotations information if function called by requester or approver
    //     //     suppliersVal2 = suppliers;
            
    //     //     for(uint j=0; j < suppliers.length; j++) {
    //     //         quotationsVal2[j] = quotations[suppliers[j]];
    //     //     }
            
    //     //     selectedSupplierVal2 = selectedSupplier;
            
    //     // } else if(suppliersList[msg.sender]) {
    //     //     // returns supplier specific information if function called by supplier
            
    //     //     suppliersVal2 = new address[](1);
    //     //     suppliersVal2[0] = msg.sender;
            
    //     //     quotationsVal2 = new address[](1);
    //     //     quotationsVal2[0] = quotations[msg.sender];
            
    //     //     selectedSupplierVal2 = selectedSupplier;
    //     // }
        
    //     //return (requester, approver, string(abi.encodePacked(items)), string(abi.encodePacked(quantity)), statusApproved, statusPOIssued, suppliersVal2, quotationsVal2, selectedSupplierVal2);
    //     return (requester);
    // }
    
    function getStatusApproved() public view returns (
        bool statusApprovedVal
    ) {
        return (statusApproved);
    }
    
    // function getItemInfo() public view returns (
    //     string[] itemsVal,
    //     uint[] quantityVal
    // ) {
        
    //     // convert mapping to array
    //     uint[] memory quantityVal2 = new uint[](items.length);
        
    //     for(uint i=0; i < items.length; i++) {
    //         quantityVal2[i] = quantity[items[i]];
    //     }

    //     return (items, quantityVal2);
    // }
    
    // function getItemQuantity() public view returns (
    //     uint[] quantityVal
    // ) {
    //     uint[] memory quantityVal2 = new uint[](items.length);
        
    //     for(uint i=0; i < items.length; i++) {
    //         quantityVal2[i] = quantity[items[i]];
    //     }
    //     return (quantityVal2);
    // }
    
    // function getrequester() public view returns (
    //     address requesterVal
    // ) {
    //     return (requester);
    // }
    
    // function getApprover() public view returns (
    //     address approverVal
    // ) {
    //     return (approver);
    // }
    
    function additem(string itemVal, uint quantityVal) public {
        require(msg.sender == requester || msg.sender == approver, "Only requester or approver can add product.");
        require(statusApproved == false, "No item can be added after RFQ is approved.");
        require(bytes(itemVal).length > 0, "Item name cannot be empty.");
        require(quantityVal > 0, "Quantity cannot be empty.");
        
        if(quantity[itemVal] == 0) {
            items[itemCount] = bytes(itemVal);
            itemsMap[itemVal] = itemCount;
            itemCount++;
        }
        quantity[itemVal] += quantityVal;
    }
    
    function removeitem(string itemVal, uint quantityVal) public {
        require(msg.sender == requester || msg.sender == approver, "Only requester or approver can remove product.");
        require(statusApproved == false, "No item can be removed after RFQ is approved.");
        require(quantity[itemVal] > 0 , "Item does not exist in RFQ.");

        if(quantityVal >= quantity[itemVal]) {
            quantity[itemVal] = 0;
            
            uint i = itemsMap[itemVal];
            uint j = itemCount - 1;
            
            items[i] = items[j];
            itemsMap[string(items[i])] = i;
            itemsMap[string(items[j])] = 0;
            items[j] = "";
            itemCount--;

        }
        else {
            quantity[itemVal] -= quantityVal;
        }
    }
    
    function approveRFQ() public {
        require(msg.sender == approver, "Only approver can approve the RFQ");
        require(statusApproved == false, "RFQ is already approved.");
        require(itemCount > 0, "No items in RFQ.");
        
        statusApproved = true;
        emit StatusChanged("RFQ is approved.", this);
    }
    
    function createQuotation(address requesterVal, address approverVal) public {
        require(requesterVal != requester && requesterVal != approver, "Quotation requester cannot be RFQ requester or approver.");
        require(approverVal != requester && approverVal != approver, "Quotation approver cannot be RFQ requester or approver.");
        require(statusApproved, "RFQ needs to be approved before quotation can be created.");
        
        new Quotation(address(this), requesterVal, approverVal, this.getItems(), this.getQuantity());
    }
    
    function submitQuotation(address supplier, address quotationVal) public {
        require(supplier != requester && supplier != approver, "The supplier cannot be the requester or approver of the RFQ.");
        require(!statusPOIssued,"Cannot submit quotation after RFQ is closed.");
        require(Quotation(quotationVal).getStatusApproved(), "Quotation not approved yet.");
        
        if(quotations[supplier] == address(0x0)) {
            suppliers.push(supplier);
            suppliersList[supplier] = true;
        }
        
        quotations[supplier] = quotationVal;
        emit StatusChanged("Quotation is submitted.", quotationVal);
    }
    
    // function removeQuotation() public {
    //     require(!statusPOIssued,"Cannot remove quotation after RFQ is closed.");
    //     require(quotations[msg.sender] > address(0x0), "No quotation found.");
        
    //     emit StatusChanged("Quotation is removed.", quotations[msg.sender]);
        
    //     quotations[msg.sender] = address(0x0);
    //     suppliersList[msg.sender] = false;
        
    //     // shift array forward after element is removed
    //     for(uint i=0; i < suppliers.length; i++) {
                
    //         if(msg.sender == suppliers[i]) {
                
    //             for(uint j=i; j < suppliers.length - 1; j++) {
    //                 suppliers[j] = suppliers[j+1];
                    
    //             }
    //             delete suppliers[suppliers.length - 1];
    //             suppliers.length--;
                
    //             break;
    //         }
    //     }
    // }  
    
    function confirmQuotation(address supplierVal) public {
        require(msg.sender == approver, "Only approver can confirm quotation.");
        require(suppliersList[supplierVal], "No quotation found.");
        
        selectedSupplier = supplierVal;
        
        // convert mapping to array
        uint[] memory quantityVal2 = new uint[](items.length);
        
        for(uint i=0; i < items.length; i++) {
            quantityVal2[i] = quantity[string(items[i])];
        }
        
        statusPOIssued = true;
        emit StatusChanged("Quotation is confirmed", Quotation(quotations[supplierVal]));
        
        PurchaseOrder po = new PurchaseOrder(requester,approver,supplierVal,address(this),quotations[supplierVal],this.getItems(),this.getQuantity(),Quotation(quotations[supplierVal]).getPrice());
        purchaseOrder = address(po);
    }
    
    function viewQuotation(address supplierVal) public view returns (uint[10] quantityVal) {
        require(msg.sender == approver, "Only requester or approver can view quotation.");
        require(suppliersList[supplierVal], "No quotation found.");
        
        return(Quotation(quotations[supplierVal]).getPrice());
    }
    
}