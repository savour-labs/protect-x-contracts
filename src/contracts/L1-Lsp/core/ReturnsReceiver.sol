// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {BaseApp} from "@/contracts/L1-Lsp/core/BaseApp.sol";
/// @title ReturnsReceiver
/// @notice Receives protocol level returns and manages who can withdraw the returns. Deployed as the
/// consensus layer withdrawal wallet and execution layer rewards wallet in the protocol.
contract ReturnsReceiver is BaseApp {
    /// @notice The manager role is responsible for managing the WITHDRAWER_ROLE.
    bytes32 public constant RECEIVER_MANAGER_ROLE = keccak256("RECEIVER_MANAGER_ROLE");

    /// @notice The withdrawer role can withdraw ETH and ERC20 tokens from this contract.
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

    /// @notice Configuration for contract initialization.
    struct Init {
        address admin;
        address manager;
        address withdrawer;
    }

    constructor() {
        _disableInitializers();
    }

    /// @notice Inititalizes the contract.
    /// @dev MUST be called during the contract upgrade to set up the proxies state.
    function initialize(Init memory init) external initializer {
        __AccessControlEnumerable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, init.admin);
        _grantRole(RECEIVER_MANAGER_ROLE, init.manager);
        _setRoleAdmin(WITHDRAWER_ROLE, RECEIVER_MANAGER_ROLE);
        _grantRole(WITHDRAWER_ROLE, init.withdrawer);
    }

    /// @notice Transfers the given amount of ETH to an address.
    /// @dev Only called by the withdrawer.
    function transfer(address payable to, uint256 amount) external onlyRole(WITHDRAWER_ROLE) {
        Address.sendValue(to, amount);
    }

    /// @notice Transfers the given amount of an ERC20 token to an address.
    /// @dev Only called by the withdrawer.
    function transferERC20(IERC20 token, address to, uint256 amount) external onlyRole(WITHDRAWER_ROLE) {
        SafeERC20.safeTransfer(token, to, amount);
    }

    receive() external payable {}
}
