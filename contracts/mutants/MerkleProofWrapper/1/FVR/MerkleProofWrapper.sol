// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import { MerkleProof } from "../cryptography/MerkleProof.sol";

contract MerkleProofWrapper {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) external pure returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }
}
