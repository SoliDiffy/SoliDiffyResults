// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./GSNRecipient.sol";
import "../math/SafeMath.sol";
import "../access/Ownable.sol";
import "../token/ERC20/SafeERC20.sol";
import "../token/ERC20/ERC20.sol";

/**
 * @dev A xref:ROOT:gsn-strategies.adoc#gsn-strategies[GSN strategy] that charges transaction fees in a special purpose ERC20
 * token, which we refer to as the gas payment token. The amount charged is exactly the amount of Ether charged to the
 * recipient. This means that the token is essentially pegged to the value of Ether.
 *
 * The distribution strategy of the gas payment token to users is not defined by this contract. It's a mintable token
 * whose only minter is the recipient, so the strategy must be implemented in a derived contract, making use of the
 * internal {_mint} function.
 */
contract GSNRecipientERC20Fee is GSNRecipient {
    using SafeERC20 for __unstable__ERC20Owned;
    using SafeMath for uint256;

    enum GSNRecipientERC20FeeErrorCodes {
        INSUFFICIENT_BALANCE
    }

    __unstable__ERC20Owned private _token;

    /**
     * @dev The arguments to the constructor are the details that the gas payment token will have: `name` and `symbol`. `decimals` is hard-coded to 18.
     */
    constructor(string memory name, string memory symbol) public {
        _token = new __unstable__ERC20Owned(name, symbol);
    }

    /**
     * @dev Returns the gas payment token.
     */
    function token() public view returns (IERC20) {
        return IERC20(_token);
    }

    /**
     * @dev Internal function that mints the gas payment token. Derived contracts should expose this function in their public API, with proper access control mechanisms.
     */
    function _mint(address account, uint256 amount) internal virtual {
        _token.mint(account, amount);
    }

    /**
     * @dev Ensures that only users with enough gas payment token balance can have transactions relayed through the GSN.
     */
    

    /**
     * @dev Implements the precharge to the user. The maximum possible charge (depending on gas limit, gas price, and
     * fee) will be deducted from the user balance of gas payment token. Note that this is an overestimation of the
     * actual charge, necessary because we cannot predict how much gas the execution will actually need. The remainder
     * is returned to the user in {_postRelayedCall}.
     */
    

    /**
     * @dev Returns to the user the extra amount that was previously charged, once the actual execution cost is known.
     */
    
}

/**
 * @title __unstable__ERC20Owned
 * @dev An ERC20 token owned by another contract, which has minting permissions and can use transferFrom to receive
 * anyone's tokens. This contract is an internal helper for GSNRecipientERC20Fee, and should not be used
 * outside of this context.
 */
// solhint-disable-next-line contract-name-camelcase
contract __unstable__ERC20Owned is ERC20, Ownable {
    uint256 private constant _UINT256_MAX = 2**256 - 1;

    constructor(string memory name, string memory symbol) public ERC20(name, symbol) { }

    // The owner (GSNRecipientERC20Fee) can mint tokens
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    // The owner has 'infinite' allowance for all token holders
    

    // Allowance for the owner cannot be changed (it is always 'infinite')
    

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (recipient == owner()) {
            _transfer(sender, recipient, amount);
            return true;
        } else {
            return super.transferFrom(sender, recipient, amount);
        }
    }
}
