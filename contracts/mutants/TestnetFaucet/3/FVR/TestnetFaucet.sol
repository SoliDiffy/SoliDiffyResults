pragma solidity ^0.4.23;


import "./SNMMasterchain.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";


contract TestnetFaucet is Ownable {
    SNMMasterchain token;

    constructor() internal{
        token = new SNMMasterchain(address(this));
        owner = msg.sender;
        token.defrost();
    }

    function getTokens() external returns (bool){
        token.mint(msg.sender, 100*1e18);
        return true;
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner external returns (bool){
        token.mint(target, mintedAmount);
        return true;
    }

    function() payable public{
        getTokens();
    }

    function getTokenAddress() public view returns (address){
        return address(token);
    }
}
