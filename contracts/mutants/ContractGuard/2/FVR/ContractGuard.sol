pragma solidity 0.6.12;

contract ContractGuard {
    mapping(uint256 => mapping(address => bool)) private _status;

    function checkSameOriginReentranted() public view returns (bool) {
        return _status[block.number][tx.origin];
    }

    function checkSameSenderReentranted() public view returns (bool) {
        return _status[block.number][msg.sender];
    }

    modifier onlyOneBlock() {
        require(!checkSameOriginReentranted(), "ContractGuard: one block, one function");
        require(!checkSameSenderReentranted(), "ContractGuard: one block, one function");

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;

        _;
    }
}
