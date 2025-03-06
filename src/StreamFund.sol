// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Tokens } from "./Tokens.sol";
import { Streamers } from "./Streamers.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { SafeTransferLib } from "lib/solady/src/utils/SafeTransferLib.sol";

interface IStreamFund {
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function supportWithETH(address streamer, bytes memory data) external payable;
    function supportWithToken(address streamer, address token, uint256 amount, bytes memory data) external;
    function getFeeCollector() external view returns (address);
    function setFeeCollector(address newCollector) external;
    function addAllowedToken(address tokenAddress, bytes memory data) external;
    function removeAllowedToken(address tokenAddress) external;
    function getAllowedToken(address tokenAddress) external view returns (bytes memory);
    function getStreamerSupport(address streamer, address token) external view returns (address, uint256);
    function getStreamerCount() external view returns (uint256);
}

contract StreamFund is AccessControl, Tokens, Streamers {
    using SafeERC20 for IERC20;

    bytes32 private constant EDITOR_ROLE = keccak256("EDITOR_ROLE");
    uint256 private constant CHAIN_ID = 421_614;
    uint256 private constant FEES = 250; // 2.5%
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address private feeCollector;

    constructor(address _feeCollector) {
        feeCollector = _feeCollector;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EDITOR_ROLE, msg.sender);
    }

    error StreamFundValidationError(string message);

    event SupportReceived(
        address indexed streamer, address indexed from, address indexed token, uint256 chain, uint256 amount, bytes data
    );
    event FeeCollectorChanged(address indexed prevCollector, address indexed newCollector, uint256 chain);

    function supportWithETH(address streamer, bytes memory data) external payable {
        if (msg.value == 0) {
            revert StreamFundValidationError("ETH amount cannot be zero");
        }
        if (block.chainid != CHAIN_ID) {
            revert StreamFundValidationError("Invalid chain ID");
        }

        uint256 fee = (msg.value * FEES) / 10_000;
        uint256 amount = msg.value - fee;
        SafeTransferLib.safeTransferETH(feeCollector, fee);
        SafeTransferLib.safeTransferETH(streamer, amount);

        _addTokenSupport(streamer, ETH, amount);
        emit SupportReceived(streamer, msg.sender, ETH, CHAIN_ID, msg.value, data);
    }

    function supportWithToken(address streamer, address token, uint256 amount, bytes memory data) external {
        if (amount == 0) {
            revert StreamFundValidationError("Token amount cannot be zero");
        }
        if (!_isTokenAvailable(token)) {
            revert StreamFundValidationError("Token not allowed");
        }
        if (block.chainid != CHAIN_ID) {
            revert StreamFundValidationError("Invalid chain ID");
        }

        uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
        if (allowance < amount) {
            revert StreamFundValidationError("Insufficient allowance");
        }

        uint256 fee = (amount * FEES) / 10_000;
        uint256 netAmount = amount - fee;
        IERC20(token).safeTransferFrom(msg.sender, feeCollector, fee);
        IERC20(token).safeTransferFrom(msg.sender, streamer, netAmount);
        _addTokenSupport(streamer, token, netAmount);

        emit SupportReceived(streamer, msg.sender, token, CHAIN_ID, amount, data);
    }

    function getFeeCollector() external view returns (address) {
        return feeCollector;
    }

    function setFeeCollector(address newCollector) external onlyRole(DEFAULT_ADMIN_ROLE) {
        address prevFeeCollector = feeCollector;
        feeCollector = newCollector;

        emit FeeCollectorChanged(prevFeeCollector, newCollector, CHAIN_ID);
    }
}
