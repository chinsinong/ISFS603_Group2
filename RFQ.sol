pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

import "./Quotation.sol";
import "./PurchaseOrder.sol";

contract RFQ {
    address private requester;
    address private approver;
    
    string[] private items;
    mapping(string => uint) private quantity;
    
    bool private statusApproved = false;
    bool private statusPOIssued = false;
    
    address[] private suppliers;
    mapping(address => bool) private suppliersList;
    mapping(address => address) private quotations;
    address private selectedSupplier;
    
    address private purchaseOrder;
    
    event RFQApproved(address rfqAddr);
    event QuotationCreated(address quotationAddr);
    event QuotationSubmitted(address quotationAddr);
    event QuotationRemoved(address quotationAddr);
    event QuotationConfirmed(address quotationAddr);
    event PurchaseOrderCreated(address purchaseOrderAddr);
    
    constructor (
        address requesterVal,
        address approverVal
        
    ) public {
        require(requesterVal != approverVal, "Requester and approver cannot be same person.");
        
        requester = requesterVal;
        approver = approverVal;
    }
    
    function getInfo() public view returns (
        address requesterVal,
        address approverVal,
        string[] itemsVal,
        uint[] quantityVal,
        bool statusApprovedVal,
        bool statusPOIssuedVal,
        address[] suppliersVal,
        address[] quotationsVal,
        address selectedSupplierVal
    ) {
        
        // convert mapping to array
        uint[] memory quantityVal2 = new uint[](items.length);
        
        for(uint i=0; i < items.length; i++) {
            quantityVal2[i] = quantity[items[i]];
        }

        address[] memory suppliersVal2 = new address[](suppliers.length);
        address[] memory quotationsVal2 = new address[](suppliers.length);
        address selectedSupplierVal2;
        
        if(msg.sender == requester || msg.sender == approver) {
            // returns all suppliers and quotations information if function called by requester or approver
            suppliersVal2 = suppliers;
            
            for(uint j=0; j < suppliers.length; j++) {
                quotationsVal2[j] = quotations[suppliers[j]];
            }
            
            selectedSupplierVal2 = selectedSupplier;
            
        } else if(suppliersList[msg.sender]) {
            // returns supplier specific information if function called by supplier
            
            suppliersVal2 = new address[](1);
            suppliersVal2[0] = msg.sender;
            
            quotationsVal2 = new address[](1);
            quotationsVal2[0] = quotations[msg.sender];
            
            selectedSupplierVal2 = selectedSupplier;
        }
        
        return (requester, approver, items, quantityVal2, statusApproved, statusPOIssued, suppliersVal2, quotationsVal2, selectedSupplierVal2);
    }
    
    function getStatusApproved() public view returns (
        bool statusApprovedVal
    ) {
        return (statusApproved);
    }
    
    function getItemInfo() public view returns (
        string[] itemsVal,
        uint[] quantityVal
    ) {
        
        // convert mapping to array
        uint[] memory quantityVal2 = new uint[](items.length);
        
        for(uint i=0; i < items.length; i++) {
            quantityVal2[i] = quantity[items[i]];
        }

        return (items, quantityVal2);
    }
    
    function getItemQuantity() public view returns (
        uint[] quantityVal
    ) {
        uint[] memory quantityVal2 = new uint[](items.length);
        
        for(uint i=0; i < items.length; i++) {
            quantityVal2[i] = quantity[items[i]];
        }
        return (quantityVal2);
    }
    
    function getrequester() public view returns (
        address requesterVal
    ) {
        return (requester);
    }
    
    function getApprover() public view returns (
        address approverVal
    ) {
        return (approver);
    }
    
    function additem(string itemVal, uint quantityVal) public {
        require(msg.sender == requester || msg.sender == approver, "Only requester or approver can add product.");
        require(statusApproved == false, "No item can be added after RFQ is approved.");
        require(bytes(itemVal).length > 0, "Item name cannot be empty.");
        require(quantityVal >0, "Quantity cannot be empty.");
        
        if(quantity[itemVal] == 0) {
            items.push(itemVal);
        }
        quantity[itemVal] += quantityVal;
    }
    
    function removeitem(string itemVal, uint quantityVal) public {
        require(msg.sender == requester || msg.sender == approver, "Only requester or approver can remove product.");
        require(statusApproved == false, "No item can be removed after RFQ is approved.");
        require(quantity[itemVal] > 0 , "Item does not exist in RFQ.");

        bytes memory a = bytes(itemVal);
        bytes memory b;
        
        if(quantityVal >= quantity[itemVal]) {
            quantity[itemVal] = 0;
            
            for(uint i=0; i < items.length; i++) {
                b = bytes(items[i]);
                
                if(keccak256(a) == keccak256(b)) {
                //if(keccak256(abi.encodePacked(itemVal)) == keccak256(abi.encodePacked(items[i]))) {
                    
                    for(uint j=i; j < items.length - 1; j++) {
                        items[j] = items[j+1];
                    }
                    delete items[items.length - 1];
                    items.length--;
                    break;
                }
            }
        }
        else {
            quantity[itemVal] -= quantityVal;
        }
    }
    
    function approveRFQ() public {
        require(msg.sender == approver, "Only approver can approve the RFQ");
        require(statusApproved == false, "RFQ is already approved.");
        require(items.length > 0, "No items in RFQ.");
        
        statusApproved = true;
        emit RFQApproved(this);
    }
    
    function createQuotation(address requesterVal, address approverVal) public {
        require(requesterVal != requester && requesterVal != approver, "Quotation requester cannot be RFQ requester or approver.");
        require(approverVal != requester && approverVal != approver, "Quotation approver cannot be RFQ requester or approver.");
        require(statusApproved, "RFQ needs to be approved before quotation can be created.");
        
        Quotation quote = new Quotation(address(this), requesterVal, approverVal);
        
        emit QuotationCreated(quote);
    }
    
    function submitQuotation(address supplier, address quotationVal) public {
        require(supplier != requester && supplier != approver, "The supplier cannot be the requester or approver of the RFQ.");
        require(!statusPOIssued,"Cannot submit quotation after RFQ is closed.");
        
        if(quotations[supplier] == address(0x0)) {
            suppliers.push(supplier);
            suppliersList[supplier] = true;
        }
        
        quotations[supplier] = quotationVal;
        emit QuotationSubmitted(Quotation(quotationVal));
    }
    
    function removeQuotation() public {
        require(!statusPOIssued,"Cannot remove quotation after RFQ is closed.");
        require(quotations[msg.sender] > address(0x0), "No quotation found.");
        
        emit QuotationRemoved(Quotation(quotations[msg.sender]));
        
        quotations[msg.sender] = address(0x0);
        suppliersList[msg.sender] = false;
        
        // shift array forward after element is removed
        for(uint i=0; i < suppliers.length; i++) {
                
            if(msg.sender == suppliers[i]) {
                
                for(uint j=i; j < suppliers.length - 1; j++) {
                    suppliers[j] = suppliers[j+1];
                    
                }
                delete suppliers[suppliers.length - 1];
                suppliers.length--;
                
                break;
            }
        }
    }  
    
    function confirmQuotation(address supplierVal) public {
        require(msg.sender == approver, "Only approver can confirm quotation.");
        require(suppliersList[supplierVal], "");
        
        selectedSupplier = supplierVal;
        
        // convert mapping to array
        uint[] memory quantityVal2 = new uint[](items.length);
        
        for(uint i=0; i < items.length; i++) {
            quantityVal2[i] = quantity[items[i]];
        }
        
        PurchaseOrder pOrder = new PurchaseOrder(requester,approver,supplierVal,address(this),quotations[supplierVal],items,quantityVal2,Quotation(quotations[supplierVal]).getPrice());
        
        statusPOIssued = true;
        purchaseOrder = address(pOrder);
        emit QuotationConfirmed(Quotation(quotations[supplierVal]));
        emit PurchaseOrderCreated(pOrder);
    }
}