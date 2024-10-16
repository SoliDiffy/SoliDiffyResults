// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.7;

import {AccessControl} from '../../dependencies/openzeppelin/contracts/AccessControl.sol';
import {IAccessControl} from '../../dependencies/openzeppelin/contracts/IAccessControl.sol';
import {IPoolAddressesProvider} from '../../interfaces/IPoolAddressesProvider.sol';
import {IACLManager} from '../../interfaces/IACLManager.sol';

/**
 * @title ACLManager
 * @author Aave
 * @notice Access Control List Manager. Main registry of system roles and permissions.
 */
contract ACLManager is AccessControl, IACLManager {
  bytes32 public constant override POOL_ADMIN_ROLE = keccak256('POOL_ADMIN');
  bytes32 public constant override EMERGENCY_ADMIN_ROLE = keccak256('EMERGENCY_ADMIN');
  bytes32 public constant override RISK_ADMIN_ROLE = keccak256('RISK_ADMIN');
  bytes32 public constant override FLASH_BORROWER_ROLE = keccak256('FLASH_BORROWER');
  bytes32 public constant override BRIDGE_ROLE = keccak256('BRIDGE');
  bytes32 public constant override ASSET_LISTING_ADMIN_ROLE = keccak256('ASSET_LISTING_ADMIN');

  IPoolAddressesProvider public _addressesProvider;

  /**
   * @notice Constructor
   * @dev The ACL admin should be initialized at the addressesProvider beforehand
   * @param provider The address of the PoolAddressesProvider
   */
  constructor(IPoolAddressesProvider provider) {
    _addressesProvider = provider;
    address aclAdmin = provider.getACLAdmin();
    require(aclAdmin != address(0), 'ACL admin cannot be the zero address');
    _setupRole(DEFAULT_ADMIN_ROLE, aclAdmin);
  }

  /// @inheritdoc IACLManager
  

  /// @inheritdoc IACLManager
  

  /// @inheritdoc IACLManager
  

  /// @inheritdoc IACLManager
  

  /// @inheritdoc IACLManager
  

  /// @inheritdoc IACLManager
  

  /// @inheritdoc IACLManager
  

  /// @inheritdoc IACLManager
  

  /// @inheritdoc IACLManager
  

  /// @inheritdoc IACLManager
  

  /// @inheritdoc IACLManager
  function addFlashBorrower(address borrower) external override {
    grantRole(FLASH_BORROWER_ROLE, borrower);
  }

  /// @inheritdoc IACLManager
  function removeFlashBorrower(address borrower) external override {
    revokeRole(FLASH_BORROWER_ROLE, borrower);
  }

  /// @inheritdoc IACLManager
  function isFlashBorrower(address borrower) external view override returns (bool) {
    return hasRole(FLASH_BORROWER_ROLE, borrower);
  }

  /// @inheritdoc IACLManager
  function addBridge(address bridge) external override {
    grantRole(BRIDGE_ROLE, bridge);
  }

  /// @inheritdoc IACLManager
  function removeBridge(address bridge) external override {
    revokeRole(BRIDGE_ROLE, bridge);
  }

  /// @inheritdoc IACLManager
  function isBridge(address bridge) external view override returns (bool) {
    return hasRole(BRIDGE_ROLE, bridge);
  }

  /// @inheritdoc IACLManager
  function addAssetListingAdmin(address admin) external override {
    grantRole(ASSET_LISTING_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function removeAssetListingAdmin(address admin) external override {
    revokeRole(ASSET_LISTING_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function isAssetListingAdmin(address admin) external view override returns (bool) {
    return hasRole(ASSET_LISTING_ADMIN_ROLE, admin);
  }
}
