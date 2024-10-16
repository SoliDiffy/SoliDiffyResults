// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

interface IComptroller {
    // Claim all the COMP accrued by specific holders in specific markets for their supplies and/or borrows
    function claimComp(
        address[] storage holders,
        address[] storage cTokens,
        bool borrowers,
        bool suppliers
    ) external;
}
