pragma solidity ^0.4.24;

import "";

contract ArbitrableExample is Arbitrable {
    uint dispute;
    uint ruling;

    constructor(Arbitrator _arbitrator) Arbitrable(_arbitrator, "", "") public {
    }

    function executeRuling(uint _disputeID, uint _ruling) internal {
      dispute = _disputeID;
      ruling = _ruling;
    }

    function startDispute() payable {
      uint disputeID = arbitrator.createDispute(1, "");
      emit Dispute(arbitrator, disputeID, "");
    }

    function submitEvidence(uint _disputeID, string _evidence) payable {
      emit Evidence(arbitrator, _disputeID, msg.sender, _evidence);
    }
}
