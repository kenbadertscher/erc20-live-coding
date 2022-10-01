// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract EthTrustFund {

 // Setup Owner  
    constructor() {
        owner = msg.sender;
    }

    address public owner;

 // Define Beneficiary
    struct Beneficiary {
        address payable walletAddress;
        string name;
        uint releaseTime;
        uint amount;
    }

    Beneficiary[] public beneficiaries; 

    event BeneficiaryCreated(address indexed walletAddress, string name);

    modifier onlyOwner() {
        require(msg.sender == owner, "You must be the owner to add a beneficiary.");
        _;
    }

 // Add Beneficiaries
    function addBeneficiary(
        address payable walletAddress,
        string calldata name,
        uint releaseTime
    ) external onlyOwner {
  
        beneficiaries.push(
            Beneficiary(walletAddress, name, releaseTime, 0)
        );

        emit BeneficiaryCreated(walletAddress, name);
    }

 // Deposit to Beneficiaries
    function depositToBeneficiary(address walletAddress) external payable {
        for(uint i = 0; i < beneficiaries.length; i++) {
            if (beneficiaries[i].walletAddress == walletAddress)  {
                beneficiaries[i].amount += msg.value;
            }
        }
    }
  
 // Get Contract Balance
    function contractBalance() external view returns (uint) {
        return address(this).balance;
    }

 // Check If We Can Withdraw
    function availableToWithdraw(address walletAddress) public view returns(bool) {
        (uint i, bool ok) = _getIndex(walletAddress);
        require(ok, "Beneficiary does not exist."); 

        if (block.timestamp > beneficiaries[i].releaseTime) {
            return true;
        }
      
        return false;
    }

 // Withdraw
    function withdraw() external {
        (uint i, bool ok) = _getIndex(msg.sender);
        require(ok, "Beneficiary does not exist");
        require(availableToWithdraw(msg.sender), "Not able to withdraw");
    
        Beneficiary storage b = beneficiaries[i];
        uint amount = b.amount;
        b.amount = 0;
        b.walletAddress.transfer(amount);
    }

 // View Beneficiaries
    function _getIndex(address walletAddress) private view returns(uint, bool) {
        for(uint i = 0; i < beneficiaries.length; i++) {
            if (beneficiaries[i].walletAddress == walletAddress) {
                return (i, true); 
            }
      
        return (type(uint).max, false);
        }
    }
}
