pragma solidity ^0.5.16;

import "../../../contracts/RBep20Immutable.sol";
import "../../../contracts/EIP20Interface.sol";

contract RTokenCollateral is RBep20Immutable {
    

    function getCashOf(address account) public view returns (uint) {
        return EIP20Interface(underlying).balanceOf(account);
    }
}
