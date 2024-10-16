// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISavingsContractV1 is IERC20 {
    

    

    

    

    
}

interface ISavingsContractV2 is IERC20 {
    // DEPRECATED but still backwards compatible
    

     // V1 & V2 (use balanceOf)

    // --------------------------------------------

     // V1 & V2

     // V1 & V2

    function depositSavings(uint256 _amount, address _beneficiary)
        external
        returns (uint256 creditsIssued); // V2

    function redeemCredits(uint256 _amount) external returns (uint256 underlyingReturned); // V2

    function redeemUnderlying(uint256 _amount) external returns (uint256 creditsBurned); // V2

    function exchangeRate() external view returns (uint256); // V1 & V2

    function balanceOfUnderlying(address _user) external view returns (uint256 underlying); // V2

    function underlyingToCredits(uint256 _underlying) external view returns (uint256 credits); // V2

    function creditsToUnderlying(uint256 _credits) external view returns (uint256 underlying); // V2

    function underlying() external view returns (IERC20 underlyingMasset); // V2
}