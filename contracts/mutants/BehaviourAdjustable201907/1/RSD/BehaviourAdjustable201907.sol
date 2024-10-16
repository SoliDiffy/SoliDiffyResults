pragma solidity >=0.5.0 <0.6.0;

import "../../../../../interfaces/IAZTEC.sol";
import "../../../../../libs/NoteUtils.sol";
import "../Behaviour201907.sol";

/**
 * @title BehaviourAdjustable201907
 * @author AZTEC
 * @dev This contract extends Behaviour201907, to add methods which enable minting/burning.
        Methods are documented in interface.
 *
 * Copyright Spilsbury Holdings Ltd 2019. All rights reserved.
 **/
contract BehaviourAdjustable201907 is Behaviour201907 {
    constructor () Behaviour201907() public {}

    function burn(bytes calldata _proofOutputs) external onlyOwner {
        require(registry.canAdjustSupply == true, "this asset is not burnable");
        // Dealing with notes representing totals
        (bytes memory oldTotal, // input notes
        bytes memory newTotal, // output notes
        ,
        ) = _proofOutputs.get(0).extractProofOutput();

        // Dealing with burned notes
        (,
        bytes memory burnedNotes,
        ,) = _proofOutputs.get(1).extractProofOutput();

        (, bytes32 oldTotalNoteHash, ) = oldTotal.get(0).extractNote();
        require(oldTotalNoteHash == registry.confidentialTotalBurned, "provided total burned note does not match");
        (, bytes32 newTotalNoteHash, ) = newTotal.get(0).extractNote();
        setConfidentialTotalBurned(newTotalNoteHash);

        // Although they are outputNotes, they are due to be destroyed - need removing from the note registry
        updateInputNotes(burnedNotes);
    }

    function mint(bytes calldata _proofOutputs) external onlyOwner {
        require(registry.canAdjustSupply == true, "this asset is not mintable");
        // Dealing with notes representing totals
        (bytes memory oldTotal, // input notes
        bytes memory newTotal, // output notes
        ,
        ) = _proofOutputs.get(0).extractProofOutput();

        // Dealing with burned notes
        (,
        bytes memory mintedNotes,
        ,) = _proofOutputs.get(1).extractProofOutput();

        (, bytes32 oldTotalNoteHash, ) = oldTotal.get(0).extractNote();
        require(oldTotalNoteHash == registry.confidentialTotalMinted, "provided total burned note does not match");
        (, bytes32 newTotalNoteHash, ) = newTotal.get(0).extractNote();
        setConfidentialTotalMinted(newTotalNoteHash);

        updateOutputNotes(mintedNotes);
    }

    function setConfidentialTotalMinted(bytes32 newTotalNoteHash) internal onlyOwner returns (bytes32) {
        registry.confidentialTotalMinted = newTotalNoteHash;
        /* return newTotalNoteHash; */
    }

    function setConfidentialTotalBurned(bytes32 newTotalNoteHash) internal onlyOwner returns (bytes32) {
        registry.confidentialTotalBurned = newTotalNoteHash;
        return newTotalNoteHash;
    }
}
