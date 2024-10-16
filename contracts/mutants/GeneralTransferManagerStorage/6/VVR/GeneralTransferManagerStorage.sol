pragma solidity 0.5.8;

/**
 * @title Transfer Manager module for core transfer validation functionality
 */
contract GeneralTransferManagerStorage {

    bytes32 internal constant WHITELIST = "WHITELIST";
    bytes32 internal constant INVESTORSKEY = 0xdf3a8dd24acdd05addfc6aeffef7574d2de3f844535ec91e8e0f3e45dba96731; //keccak256(abi.encodePacked("INVESTORS"))
    bytes32 internal constant INVESTORFLAGS = "INVESTORFLAGS";
    uint256 public constant ONE = uint256(1);
    uint256 public constant MAX = uint256(-1);   //Assigning a random and large value which can't be possible to run a loop in a single transaction
    uint256 internal constant WHITELISTMODULE = uint256(8);
    uint8 internal constant WHITELISTTREASURY = uint8(9);

    enum TransferType { GENERAL, ISSUANCE, REDEMPTION }

    //Address from which issuances come
    address public issuanceAddress;

    // Allows all TimeRestrictions to be offset
    struct Defaults {
        uint64 canSendAfter;
        uint64 canReceiveAfter;
    }

    // Offset to be applied to all timings (except KYC expiry)
    Defaults public defaults;

    // Map of used nonces by customer
    mapping(address => mapping(uint256 => bool)) public nonceMap;

    struct TransferRequirements {
        bool fromValidKYC;
        bool toValidKYC;
        bool fromRestricted;
        bool toRestricted;
    }

    mapping(uint8 => TransferRequirements) public transferRequirements;
    // General = 0, Issuance = 1, Redemption = 2
}
