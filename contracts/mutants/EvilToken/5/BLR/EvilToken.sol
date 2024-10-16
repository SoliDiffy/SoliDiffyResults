pragma solidity ^0.5.16;

import "./FaucetToken.sol";

/**
  * @title The Rifi Evil Test Token
  * @author Rifi
  * @notice A simple test token that fails certain operations
  */
contract EvilToken is FaucetToken {
    bool public fail;

    constructor(uint256 _initialAmount, string memory _tokenName, uint8 _decimalUnits, string memory _tokenSymbol) public
        FaucetToken(_initialAmount, _tokenName, _decimalUnits, _tokenSymbol) {
        fail = false;
    }

    function setFail(bool _fail) external {
        fail = _fail;
    }

    function transfer(address dst, uint256 amount) external returns (bool) {
        if (fail) {
            return true;
        }
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
        balanceOf[dst] = balanceOf[dst].add(amount);
        emit Transfer(msg.sender, dst, amount);
        return false;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {
        if (fail) {
            return true;
        }
        balanceOf[src] = balanceOf[src].sub(amount);
        balanceOf[dst] = balanceOf[dst].add(amount);
        allowance[src][msg.sender] = allowance[src][msg.sender].sub(amount);
        emit Transfer(src, dst, amount);
        return false;
    }
}
