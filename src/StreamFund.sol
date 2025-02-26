// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.25 <0.9.0;

import { Tokens } from "./Tokens.sol";
import { Streamers } from "./Streamers.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { SafeTransferLib } from "lib/solady/src/utils/SafeTransferLib.sol";

contract StreamFund is AccessControl, Tokens, Streamers {
    using SafeERC20 for IERC20;

    bytes32 private constant EDITOR_ROLE = keccak256("EDITOR_ROLE");
    uint256 private constant CHAIN_ID = 84_532;
    uint256 private constant MAX_MESSAGE_LENGTH = 200;
    uint256 private constant FEES = 100; // 1%
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address private feeCollector;

    constructor(address _feeCollector) {
        feeCollector = _feeCollector;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EDITOR_ROLE, msg.sender);
    }

    error StreamFundValidationError(string message);

    event SupportReceived(
        address indexed streamer, address indexed from, address token, uint256 amount, uint256 chain, string message
    );
    event FeeCollectorChanged(address indexed newCollector);

    function supportWithETH(address streamer, string memory message) external payable {
        if (msg.value == 0) {
            revert StreamFundValidationError("ETH amount cannot be zero");
        }
        if (bytes(message).length > MAX_MESSAGE_LENGTH) {
            revert StreamFundValidationError("Message length exceeded");
        }
        if (block.chainid != CHAIN_ID) {
            revert StreamFundValidationError("Invalid chain ID");
        }

        uint256 fee = (msg.value * FEES) / 10_000;
        uint256 amount = msg.value - fee;
        SafeTransferLib.safeTransferETH(feeCollector, fee);
        SafeTransferLib.safeTransferETH(streamer, amount);

        _addTokenSupport(streamer, ETH, amount);
        emit SupportReceived(streamer, msg.sender, ETH, msg.value, CHAIN_ID, message);
    }

    function supportWithToken(address streamer, address token, uint256 amount, string memory message) external {
        if (amount == 0) {
            revert StreamFundValidationError("Token amount cannot be zero");
        }
        if (!_isTokenAvailable(token)) {
            revert StreamFundValidationError("Token not allowed");
        }
        if (bytes(message).length > MAX_MESSAGE_LENGTH) {
            revert StreamFundValidationError("Message length exceeded");
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

        emit SupportReceived(streamer, msg.sender, token, amount, CHAIN_ID, message);
    }

    function getFeeCollector() external view returns (address) {
        return feeCollector;
    }

    function setFeeCollector(address newCollector) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeCollector = newCollector;

        emit FeeCollectorChanged(newCollector);
    }
}
