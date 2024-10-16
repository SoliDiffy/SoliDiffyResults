pragma solidity ^0.4.24;

import "../token/ERC721/ERC721Full.sol";
import "../token/ERC721/ERC721Mintable.sol";
import "../token/ERC721/ERC721MetadataMintable.sol";
import "../token/ERC721/ERC721Burnable.sol";

/**
 * @title ERC721MintableBurnableImpl
 */
contract ERC721MintableBurnableImpl
  is ERC721Full, ERC721Mintable, ERC721MetadataMintable, ERC721Burnable {

  constructor()
    ERC721Mintable()
    ERC721Full("Test", "TEST")
    internal
  {
  }
}
