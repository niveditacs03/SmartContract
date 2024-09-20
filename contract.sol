// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BankContract {
    address public alice;
    address public bob;
    address public bank;

    uint256 public aliceBalance;
    uint256 public bobBalance;
    uint256 public bankBalance;

    uint256 public alice_principalAmount;
    uint256 public bob_principalAmount;
    uint256 public alice_maturityPeriod;
    uint256 public bob_maturityPeriod;
    uint256 public interestInterval;
    uint256 public timestamp;                                 
    uint256 public lastAliceInterestPayment;
    uint256 public lastBobInterestPayment;
    uint256 public marketprice;
    uint256 public alice_fixed_rate;
    uint256 public min_value;
    uint256 public max_value;

    constructor(
        address _alice,
        address _bob,
        address _bank,
        uint256 _alicePrincipalAmount,
        uint256 _bobPrincipalAmount,
        uint256 _alice_maturityPeriod,
        uint256 _bob_maturityPeriod,
        uint256 _interestInterval
    ) {
        alice = _alice;
        bob = _bob;
        bank = _bank;

        aliceBalance = 10000; 
        bobBalance = 13000;   
        bankBalance = 1000;  

        alice_principalAmount = _alicePrincipalAmount;
        bob_principalAmount = _bobPrincipalAmount;
        alice_maturityPeriod = _alice_maturityPeriod;
        bob_maturityPeriod = _bob_maturityPeriod;

        interestInterval = _interestInterval;
        timestamp = block.timestamp;
        lastAliceInterestPayment = block.timestamp;
        lastBobInterestPayment = block.timestamp;
    }

modifier onlyBank() {
        require(msg.sender == bank, "Only the bank can call this function");
        _;
    }
    
    modifier onlyAliceorbob() {
        require(msg.sender == alice || msg.sender == bob, "Only Alice or bob can call this function");
        _;
    }
    
    
    
    bool premiumProcessed = false;

    function calloption() public onlyAliceorbob {
        if (alice_principalAmount == bob_principalAmount &&  alice_maturityPeriod==bob_maturityPeriod) {
            if (!premiumProcessed) {
                uint256 premium_amount = 100;
                aliceBalance -= premium_amount;
                bobBalance += premium_amount;
                premiumProcessed = true;  // Set the flag to true after processing
        }
            if (block.timestamp < timestamp + alice_maturityPeriod) {
                if (marketprice >= min_value && marketprice <= max_value) {
                uint256 timePassed;
                uint256 numberOfInterval;
                uint256 max_interval;

                // Calculate time passed since the last interest payment
                timePassed = block.timestamp-lastAliceInterestPayment;

                if (timePassed < alice_maturityPeriod) {
                    // Calculate the number of completed intervals
                    max_interval=alice_maturityPeriod/interestInterval;
                   numberOfInterval = timePassed / interestInterval;

                    if (numberOfInterval < max_interval) {
                        uint256 interest = calculateInterest(alice_principalAmount, marketprice);
                        aliceBalance -= interest;
                        bobBalance += interest;
                        lastAliceInterestPayment += interestInterval;

                        uint256 bobinterest = calculateInterest(bob_principalAmount, alice_fixed_rate);
                        bobBalance -= bobinterest;
                        aliceBalance += bobinterest;
                        lastBobInterestPayment += interestInterval;
                    }
                }
            }
        }
    }}

    function putoption() public onlyAliceorbob {

       if (alice_principalAmount == bob_principalAmount && alice_maturityPeriod == bob_maturityPeriod) {
            if (!premiumProcessed) {
            uint256 premium_amount = 100;
            aliceBalance += premium_amount;
            bobBalance -= premium_amount;
            premiumProcessed = true;  // Set the flag to true after processing
            }
           if (block.timestamp < timestamp + bob_maturityPeriod) {
                 if( marketprice>alice_fixed_rate){
                     if (msg.sender == bob) {
                     uint256 timePassed;
                     uint256 numberOfIntervals;
                     uint256 max_interval;
                     timePassed = block.timestamp - lastBobInterestPayment;

                         if (timePassed <bob_maturityPeriod) {
                            max_interval=bob_maturityPeriod/interestInterval;
                            numberOfIntervals = timePassed / interestInterval;

                             if (numberOfIntervals < max_interval) {

        
                             uint256 bobinterest = calculateInterest(bob_principalAmount,alice_fixed_rate);
                             bobBalance-=bobinterest;
                             aliceBalance+=bobinterest;
                             lastBobInterestPayment+= interestInterval;
             
                             uint256 interest = calculateInterest(alice_principalAmount, marketprice);
                             aliceBalance -= interest;
                             bobBalance+= interest;
                             lastAliceInterestPayment += interestInterval;
                            }
                         }
                     }
                 }
             }
         }
     }
    
    
    function calculateInterest(uint256 principalAmount, uint256 interestRate) internal pure returns (uint256) {
        return (principalAmount * interestRate) / 100;
    }
    
    function payInterest()public onlyAliceorbob  {
    uint256 timePassed;
    uint256 numberOfIntervals;
    uint256 max_interval;

    if (msg.sender == alice) {
        if (block.timestamp < timestamp + alice_maturityPeriod) {
        timePassed = block.timestamp - lastAliceInterestPayment;

        if (timePassed < alice_maturityPeriod) {
        max_interval=alice_maturityPeriod/interestInterval;
        numberOfIntervals = timePassed / interestInterval;

        if (numberOfIntervals <max_interval) {

        uint256 interest = calculateInterest(aliceBalance, alice_fixed_rate);
        bankBalance += interest;
        aliceBalance -= interest;
        lastAliceInterestPayment += interestInterval;
    } }}}
    else if (msg.sender == bob) {
        if (block.timestamp < timestamp + bob_maturityPeriod) {
        timePassed = block.timestamp - lastBobInterestPayment;

        if (timePassed <bob_maturityPeriod) {

        // Calculate the number of completed intervals
         max_interval=bob_maturityPeriod/interestInterval;
        numberOfIntervals = timePassed / interestInterval;

        if (numberOfIntervals < max_interval) {
        uint256 interest = calculateInterest(bobBalance, marketprice);
        bankBalance += interest;
        bobBalance -= interest;
        lastBobInterestPayment += interestInterval;
    }}}}
    }
    function setMarketPrice(uint256 _marketprice,uint256 _alice_fixed_rate) external onlyBank {
        marketprice = _marketprice;
        alice_fixed_rate = _alice_fixed_rate;}
    function Alice(uint256 _min_value, uint256 _max_value) external onlyAliceorbob {
         min_value = _min_value;
        max_value=_max_value;}
         
    
    function getBalances() external view returns (uint256, uint256, uint256) {
        return (aliceBalance, bobBalance, bankBalance);
    }
}
