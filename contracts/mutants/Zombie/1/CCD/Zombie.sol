pragma solidity 0.4.18;


contract Zombie {
    address public owner;

    

    function() public payable {}

    function escapeHatch() public {
        selfdestruct(owner);
    }

}
