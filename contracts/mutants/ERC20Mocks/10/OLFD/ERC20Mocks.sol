// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

contract ERC20TrueReturner {

    

    
    
    

}

contract ERC20FalseReturner {

    

    
    
    

}

contract ERC20NoReturner {

    

    
    
    

}

contract ERC20Reverter {

    

    function transferFrom(address from, address to, uint256 value) external pure returns (bool) {
        require(false);
    }
    
    function approve(address to, uint256 value) external pure returns (bool) {
        require(false);
    }

}
