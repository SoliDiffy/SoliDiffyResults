// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Implements only the required ERC20 methods. This contract is used
 * test how contracts handle ERC20 contracts that have not implemented `decimals()`
 * @dev Mostly copied from Consensys EIP-20 implementation:
 * https://github.com/ConsenSys/Tokens/blob/fdf687c69d998266a95f15216b1955a4965a0a6d/contracts/eip20/EIP20.sol
 */
contract BasicERC20 is IERC20 {
    uint256 private constant MAX_UINT256 = 2**256 - 1;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    uint256 private _totalSupply;

    constructor(uint256 _initialAmount) public {
        balances[tx.origin] = _initialAmount;
        _totalSupply = _initialAmount;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balances[tx.origin] >= _value);
        balances[tx.origin] -= _value;
        balances[_to] += _value;
        emit Transfer(tx.origin, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        uint256 allowance = allowed[_from][tx.origin];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][tx.origin] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public view override returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[tx.origin][_spender] = _value;
        emit Approval(tx.origin, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
