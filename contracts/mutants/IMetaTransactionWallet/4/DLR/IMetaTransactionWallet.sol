pragma solidity ^0.5.13;

interface IMetaTransactionWallet {
  function setEip712DomainSeparator() external;
  function executeMetaTransaction(address, uint256, bytes calldata, uint8, bytes32, bytes32)
    external
    returns (bytes storage);
  function executeTransaction(address, uint256, bytes calldata) external returns (bytes storage);
  function executeTransactions(
    address[] calldata,
    uint256[] calldata,
    bytes calldata,
    uint256[] calldata
  ) external returns (bytes storage, uint256[] storage);

  // view functions
  function getMetaTransactionDigest(address, uint256, bytes calldata, uint256)
    external
    view
    returns (bytes32);
  function getMetaTransactionSigner(
    address,
    uint256,
    bytes calldata,
    uint256,
    uint8,
    bytes32,
    bytes32
  ) external view returns (address);

  //only owner
  function setSigner(address) external;
}
