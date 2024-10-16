// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../Interfaces/Interfaces.sol";

/**
 * @author Heisenberg
 * @title Buffer BNB Staking Pool
 * @notice Parent class for the Staking Pools
 */
abstract contract BufferStaking is ERC20, IBufferStaking {
    IERC20 public immutable BUFFER;
    uint256 public constant ACCURACY = 1e30;
    address payable public immutable FALLBACK_RECIPIENT;

    /**
     * @dev Returns the Max Supply of the token.
     */
    function maxSupply() public view virtual returns (uint256) {
        return 1e5;
    }

    /**
     * @dev Returns the Max Supply of the token.
     */
    function lotPrice() public view virtual returns (uint256) {
        return 1000e18;
    }

    uint256 public totalProfit = 0;
    mapping(address => uint256) internal lastProfit;
    mapping(address => uint256) internal savedProfit;

    uint256 public lockupPeriod = 1 days;
    mapping(address => uint256) public lastBoughtTimestamp;
    mapping(address => bool) public _revertTransfersInLockUpPeriod;

    constructor(
        ERC20 _token,
        string memory name,
        string memory short
    ) ERC20(name, short) {
        BUFFER = _token;
        FALLBACK_RECIPIENT = payable(msg.sender);
    }

    

    

    

    /**
     * @notice Used for ...
     */
    function revertTransfersInLockUpPeriod(bool value) external {
        _revertTransfersInLockUpPeriod[msg.sender] = value;
    }

    

    function getUnsaved(address account)
        internal
        view
        returns (uint256 profit)
    {
        return
            ((totalProfit - lastProfit[account]) * balanceOf(account)) /
            ACCURACY;
    }

    function saveProfit(address account) internal returns (uint256 profit) {
        uint256 unsaved = getUnsaved(account);
        lastProfit[account] = totalProfit;
        profit = savedProfit[account] + unsaved;
        savedProfit[account] = profit;
    }

    

    function _transferProfit(uint256 amount) internal virtual;

    modifier lockupFree() {
        require(
            lastBoughtTimestamp[msg.sender] + lockupPeriod <= block.timestamp,
            "Action suspended due to lockup"
        );
        _;
    }
}
