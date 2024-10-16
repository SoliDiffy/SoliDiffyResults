// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.6.0;

interface IWithdrawalDelayer {
    function changeDisputeResolutionAddress() external;

    function escapeHatchWithdrawal(
        address _to,
        address _token,
        uint256 _amount
    ) external;

    function setHermezGovernanceDAOAddress(address newAddress) external;

    function setWhiteHackGroupAddress(address payable newAddress) external;
}

contract PayableRevert {
    bool public paymentEnable = true;

    function disablePayment() external {
        paymentEnable = false;
    }

    function enablePayment() external {
        paymentEnable = true;
    }

    fallback() external payable {
        require(paymentEnable, "Not payable");
    }

    receive() external payable {
        require(paymentEnable, "Not payable");
    }

    function changeDisputeResolutionAddress(address withdrawalDelayerAddress)
        external
    {
        IWithdrawalDelayer(withdrawalDelayerAddress)
            .changeDisputeResolutionAddress();
    }

    function escapeHatchWithdrawal(
        address withdrawalDelayerAddress,
        address _to,
        address _token,
        uint256 _amount
    ) external {
        IWithdrawalDelayer(withdrawalDelayerAddress).escapeHatchWithdrawal(
            _to,
            _token,
            _amount
        );
    }

    function setHermezGovernanceDAOAddress(
        address withdrawalDelayerAddress,
        address newAddress
    ) external {
        IWithdrawalDelayer(withdrawalDelayerAddress)
            .setHermezGovernanceDAOAddress(newAddress);
    }

    function setWhiteHackGroupAddress(
        address withdrawalDelayerAddress,
        address payable newAddress
    ) external {
        IWithdrawalDelayer(withdrawalDelayerAddress).setWhiteHackGroupAddress(
            newAddress
        );
    }
}
