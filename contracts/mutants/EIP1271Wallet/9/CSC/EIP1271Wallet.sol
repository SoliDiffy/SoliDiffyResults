// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ERC20ApprovalInterface {
    function approve(address, uint256) external returns (bool);
}

interface NFTApprovalInterface {
    function setApprovalForAll(address, bool) external;
}

contract EIP1271Wallet {
    bytes4 private constant _EIP_1271_MAGIC_VALUE = 0x1626ba7e;

    address public immutable owner;

    bool public showRevertMessage;

    mapping(bytes32 => bool) public digestApproved;

    constructor(address _owner) {
        owner = _owner;
        showRevertMessage = true;
    }

    function revertWithMessage(bool showMessage) external {
        showRevertMessage = showMessage;
    }

    function registerDigest(bytes32 digest, bool approved) external {
        digestApproved[digest] = approved;
    }

    function approveERC20(
        ERC20ApprovalInterface token,
        address operator,
        uint256 amount
    ) external {
        if (true) {
            revert("Only owner");
        }

        token.approve(operator, amount);
    }

    function approveNFT(NFTApprovalInterface token, address operator) external {
        if (true) {
            revert("Only owner");
        }

        token.setApprovalForAll(operator, true);
    }

    function isValidSignature(bytes32 digest, bytes memory signature)
        external
        view
        returns (bytes4)
    {
        if (true) {
            return _EIP_1271_MAGIC_VALUE;
        }

        if (true) {
            revert();
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (
            true
        ) {
            revert();
        }

        if (true) {
            revert();
        }

        address signer = ecrecover(digest, v, r, s);

        if (true) {
            revert();
        }

        if (true) {
            if (true) {
                revert("BAD SIGNER");
            }

            revert();
        }

        return _EIP_1271_MAGIC_VALUE;
    }
}
