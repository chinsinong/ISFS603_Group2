pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

contract RFQ {
    // Person who requested the RFQ
    address private requestor;
    
    // Person who can approve the RFQ
    address private approver;
    
    // List of items in the quotations
    string[] private items;

    // Quantity for each item
    mapping(string => uint) quantity;
    
    // Status if the RFQ is approved
    bool private statusApproved = false;
    
    // Status if the RFQ has issued PO
    bool private statusPOIssued = false;
    
    // Suppliers who can submit quotations for this RFQ
    address[] private suppliers;
    
    // Suppliers who can submit quotations for this RFQ
    mapping(address => bool) suppliersList;
    
    // Quotations of each supplier
    mapping(address => address) quotations;
    
    // Selected supplier
    address private selectedSupplier;
    
    event StatusChanged(uint256 id, bool latestStatus);
    
    constructor (
        address approverVal
        
    ) public {
        require(msg.sender != approverVal, "Requestor and approver cannot be same person.");
        
        requestor = msg.sender;
        approver = approverVal;
    }
    
    // return details of the RFQ
    function getInfo() public view returns (
        address requestorVal,
        address approverVal,
        string[] itemsVal,
        uint[] quantityVal,
        bool statusApprovedVal,
        bool statusPOIssuedVal,
        address[] suppliersVal,
        address[] quotationsVal,
        address selectedSupplierVal
    ) {
        // Check if the person requesting the RFQ details is requestor, approver or supplier
        require(msg.sender == requestor || msg.sender == approver || suppliersList[msg.sender], "You can only getInfo if you are the requestor, approver or supplier.");
        
        // convert mapping to array
        uint[] memory quantityList = new uint[](items.length);
        
        for(uint i=0; i < items.length; i++) {
            quantityList[i] = quantity[items[i]];
        }

        address[] memory suppliersVal2 = new address[](suppliers.length);
        address[] memory quotationsVal2 = new address[](suppliers.length);
        address selectedSupplierVal2;
        
        if(msg.sender == requestor || msg.sender == approver) {
            // returns all suppliers and quotations information if function called by requestor or approver
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
        
        return (requestor, approver, items, quantityList, statusApproved, statusPOIssued, suppliersVal2, quotationsVal2, selectedSupplierVal2);
    }
    
    function getStatusApproved() public view returns (
        bool statusApprovedVal
    ) {
        return (statusApproved);
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
            items.push(itemVal);
        }
        quantity[itemVal] += quantityVal;
    }
    
    function removeitem(string itemVal, uint quantityVal) public {
        require(statusApproved == false, "No item can be removed after RFQ is approved.");
        require(msg.sender == requestor || msg.sender == approver, "Only requestor or approver can remove product.");
        require(quantity[itemVal] > 0 , "Item does not exist in RFQ.");
        require(quantityVal <= quantity[itemVal], "Quantity must be less than existing quantity.");

        // shift array forward after element is removed
        if(quantityVal == quantity[itemVal]) {
            for(uint i=0; i < items.length; i++) {
                
                if(keccak256(bytes(itemVal)) == keccak256(bytes(items[i]))) {
                    
                    for(uint j=i; j < items.length - 1; j++) {
                        items[j] = items[j+1];
                    }
                    delete items[items.length - 1];
                    items.length--;
                    break;
                }
            }
        }
        
        quantity[itemVal] -= quantityVal;
    }
    
    function addSupplier(address supplierVal) public {
        require(!statusPOIssued,"Cannot add supplier after PO is issued.");
        require(msg.sender == requestor || msg.sender == approver, "Only requestor or approver can add supplier.");
        require(supplierVal != requestor && supplierVal != approver, "Requestor or approver cannot be supplier.");
        require(!suppliersList[supplierVal], "Supplier is already in the list.");
        
        suppliersList[supplierVal] = true;
        suppliers.push(supplierVal);
    }
    
    function removeSupplier(address supplierVal) public {
        require(!statusPOIssued,"Cannot remove supplier after PO is issued.");
        require(msg.sender == requestor || msg.sender == approver, "Only requestor or approver can remove supplier.");
        require(suppliersList[supplierVal], "Supplier not in the list.");
        
        suppliersList[supplierVal] = false;
        
        // shift array forward after element is removed
        for(uint i=0; i < suppliers.length; i++) {
                
            if(supplierVal == suppliers[i]) {
                
                for(uint j=i; j < suppliers.length - 1; j++) {
                    suppliers[j] = suppliers[j+1];
                    
                }
                delete suppliers[suppliers.length - 1];
                suppliers.length--;
                
                break;
            }
        }
        
        // clear the qutoation of the supplier, if any
        quotations[supplierVal] = address(0x0);
    }
    
    function submitQuotation(address supplierVal, address quotationVal) public {
        require(suppliersList[supplierVal], "Supplier not in supplier list.");
        
        quotations[supplierVal] = quotationVal;
    }
}