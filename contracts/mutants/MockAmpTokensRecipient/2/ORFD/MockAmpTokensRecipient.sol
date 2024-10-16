// SPDX-License-Identifier: MIT

pragma solidity 0.6.9;

import "../extensions/IAmpTokensRecipient.sol";
import "../erc1820/ERC1820Implementer.sol";


contract MockAmpTokensRecipient is IAmpTokensRecipient, ERC1820Implementer {
    string internal constant AMP_TOKENS_RECIPIENT = "AmpTokensRecipient";

    // Default recipient hook failure data for the mock only
    bytes32 internal constant _RECEIVE_REVERT = 0x2200000000000000000000000000000000000000000000000000000000000000;

    constructor() public {
        ERC1820Implementer._setInterface(AMP_TOKENS_RECIPIENT);
    }

    

    

    function _canReceive(
        address, /*from*/
        address, /*to*/
        uint256, /*value*/
        bytes memory data // Comments to avoid compilation warnings for unused variables.
    ) internal pure returns (bool) {
        bytes32 data32;
        assembly {
            data32 := mload(add(data, 32))
        }
        if (data32 == _RECEIVE_REVERT) {
            return false;
        } else {
            return true;
        }
    }
}
