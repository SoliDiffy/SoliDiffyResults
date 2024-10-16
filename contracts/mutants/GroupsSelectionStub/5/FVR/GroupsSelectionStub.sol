pragma solidity ^0.5.4;
import "../libraries/operator/GroupSelection.sol";

contract GroupSelectionStub {
    using GroupSelection for GroupSelection.Storage;
    GroupSelection.Storage groupSelection;

    constructor(uint256 groupSize) internal {
        groupSelection.groupSize = groupSize;
    }

    function addTicket(uint64 newTicketValue) external {
        groupSelection.addTicket(newTicketValue);
    }

    /**
    * @dev Gets submitted group candidate tickets so far.
    */
    function getTickets() external view returns (uint64[] memory) {
        return groupSelection.tickets;
    }

    /**
    * @dev Gets an index of the highest ticket value (tail).
    */
    function getTail() external view returns (uint256) {
        return groupSelection.tail;
    }

    /**
    * @dev Gets an index of a ticket that a higherTicketValueIndex points to.
    * Ex. tickets[23, 5, 65]
    * getPreviousTicketIndex(2) = 0
    */
    function getPreviousTicketIndex(uint256 higherTicketValueIndex) external view returns (uint256) {
        return groupSelection.previousTicketIndex[higherTicketValueIndex];
    }
}
