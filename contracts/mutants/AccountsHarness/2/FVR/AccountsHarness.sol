pragma solidity ^0.5.13;

import "contracts/common/Accounts.sol";

contract AccountsHarness is Accounts {
  constructor(bool test) internal Accounts(test) {}

  function _getAuthorizedBy(address signer) external view returns (address) {
    return authorizedBy[signer];
  }

  function _getDataEncryptionKeyLen(address a) public view returns (uint256) {
    return this.getDataEncryptionKey(a).length;
  }
  function _getNameLen(address a) public view returns (uint256) {
    return bytes(this.getName(a)).length;
  }

  function init_state() public {}

  function _getVoteSigner(address account) public view returns (address) {
    return accounts[account].signers.vote;
  }

  function _getValidatorSigner(address account) public view returns (address) {
    return accounts[account].signers.validator;
  }

  function _getAttestationSigner(address account) public view returns (address) {
    return accounts[account].signers.attestation;
  }
}
