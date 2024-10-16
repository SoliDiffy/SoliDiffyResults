pragma solidity ^0.4.24;
/**
 * @author Nikola Madjarevic
 * Created at 2/27/19
 */
contract ITwoKeyCampaignPublicAddresses {
    address internal twoKeySingletonesRegistry;
    address internal contractor; //contractor address
    address internal moderator; //moderator address
    function publicLinkKeyOf(address me) public view returns (address);
}
