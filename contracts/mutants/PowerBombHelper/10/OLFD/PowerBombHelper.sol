// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IPowerBomb {
    function depositByHelper(address token, uint amount, address depositor) external;
    
    
    
    
    
}

contract PowerBombHelper is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IPowerBomb public powerBombBTC;
    IPowerBomb public powerBombETH;
    IERC20Upgradeable constant BTC = IERC20Upgradeable(0x3095c7557bCb296ccc6e363DE01b760bA031F2d9);
    IERC20Upgradeable constant ETH = IERC20Upgradeable(0x6983D1E6DEf3690C4d616b13597A09e6193EA013);

    function initialize(IPowerBomb _powerBombBTC, IPowerBomb _powerBombETH) external initializer {
        __Ownable_init();

        powerBombBTC = _powerBombBTC;
        powerBombETH = _powerBombETH;
    }

    function deposit(IERC20Upgradeable token, uint amount, uint btcSplit, uint ethSplit) external {
        require(btcSplit + ethSplit == 10000, "Helper: invalid deposit split");
        token.safeTransferFrom(msg.sender, address(this), amount);

        uint tokenAmtForBTC = amount * btcSplit / 10000;
        token.safeApprove(address(powerBombBTC), tokenAmtForBTC);
        powerBombBTC.depositByHelper(address(token), tokenAmtForBTC, msg.sender);

        uint tokenAmtForETH = amount - tokenAmtForBTC;
        token.safeApprove(address(powerBombETH), tokenAmtForETH);
        powerBombETH.depositByHelper(address(token), tokenAmtForETH, msg.sender);
    }

    

    

    function setPowerBombBTC(IPowerBomb _powerBombBTC) external onlyOwner {
        powerBombBTC = _powerBombBTC;
    }

    function setPowerBombETH(IPowerBomb _powerBombETH) external onlyOwner {
        powerBombETH = _powerBombETH;
    }

    /// return All pool in USD (6 decimals)
    

    

    /// return User balance in USD (6 decimals)
    
}
