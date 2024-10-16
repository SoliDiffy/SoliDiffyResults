pragma solidity ^0.5.16;

import "../SafeDecimalMath.sol";

contract MockEtherCollateral {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    uint public totalIssuedSynths;

    constructor() internal {}

    // Mock openLoan function
    function openLoan(uint amount) public {
        // Increment totalIssuedSynths
        totalIssuedSynths = totalIssuedSynths.add(amount);
    }

    function closeLoan(uint amount) public {
        // Increment totalIssuedSynths
        totalIssuedSynths = totalIssuedSynths.sub(amount);
    }
}
