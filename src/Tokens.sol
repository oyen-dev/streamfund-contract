// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface ITokens {
    function addAllowedToken(address tokenAddress, bytes memory data) external;
    function removeAllowedToken(address tokenAddress) external;
    function getAllowedToken(address tokenAddress) external view returns (bytes memory);
}

contract Tokens is AccessControl {
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    bytes32 private constant EDITOR_ROLE = keccak256("EDITOR_ROLE");
    uint256 private constant CHAIN_ID = 4202;
    mapping(address tokenAddress => bytes info) private allowedTokens;
    EnumerableMap.UintToAddressMap private tokens;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EDITOR_ROLE, msg.sender);
    }

    error TokenValidationError(string message);

    event TokenAdded(address indexed tokenAddress, uint256 chain, uint8 decimals, bytes data);
    event TokenRemoved(address indexed tokenAddress, uint256 chain);

    /**
     * @dev Add a new token to the allowed tokens list.
     * Reverts with a `TokenValidationError` if the token address is zero,
     * the token decimals are zero, or the token symbol or name are empty.
     * Also reverts if the token already exists in the list.
     * @param tokenAddress of the token
     * @param data additional encoded data for the token
     */
    function addAllowedToken(address tokenAddress, bytes memory data) external onlyRole(EDITOR_ROLE) {
        if (tokenAddress == address(0)) {
            revert TokenValidationError("Token address cannot be zero");
        }
        if (_isTokenAvailable(tokenAddress)) {
            revert TokenValidationError("Token already exists");
        }

        uint8 decimals = IERC20Metadata(tokenAddress).decimals();
        string memory symbol = IERC20Metadata(tokenAddress).symbol();
        string memory name = IERC20Metadata(tokenAddress).name();
        (string memory params) = abi.decode(data, (string));

        data = abi.encode(tokenAddress, name, symbol, decimals, params);

        allowedTokens[tokenAddress] = data;
        tokens.set(tokens.length(), tokenAddress);

        emit TokenAdded(tokenAddress, CHAIN_ID, decimals, data);
    }

    /**
     * @dev Removes a token from the allowed tokens list.
     * Reverts with a `TokenValidationError` if the token does not exist in the list.
     * @param tokenAddress The address of the token contract to remove
     */
    function removeAllowedToken(address tokenAddress) external onlyRole(EDITOR_ROLE) {
        if (tokenAddress == address(0)) {
            revert TokenValidationError("Token address cannot be zero");
        }
        uint256 index = _getTokenIndex(tokenAddress);
        delete allowedTokens[tokenAddress];
        tokens.remove(index);

        emit TokenRemoved(tokenAddress, CHAIN_ID);
    }

    /**
     * @notice Retrieves the details of an allowed token.
     * @param tokenAddress The address of the token to retrieve.
     * @return bytes the additional data for the token.
     */
    function getAllowedToken(address tokenAddress) external view returns (bytes memory) {
        return allowedTokens[tokenAddress];
    }

    /**
     * @dev Checks if a token is available in the allowed tokens list.
     * @param tokenAddress The address of the token to check.
     * @return bool Returns true if the token is available, false otherwise.
     */
    function _isTokenAvailable(address tokenAddress) internal view returns (bool) {
        return allowedTokens[tokenAddress].length != 0;
    }

    /**
     * @dev Internal function to get the index of a token in the `tokens` mapping by its address.
     * Iterates through the `tokens` mapping to find the token address and returns its index.
     * Reverts with a `TokenValidationError` if the token does not exist in the mapping.
     *
     * @param tokenAddress The address of the token to find.
     * @return index The index of the token in the `tokens` mapping.
     */
    function _getTokenIndex(address tokenAddress) internal view returns (uint256 index) {
        for (uint256 i = 0; i < tokens.length(); i++) {
            (uint256 key, address value) = tokens.at(i);
            if (value == tokenAddress) {
                return key;
            }
        }
        revert TokenValidationError("Token does not exist");
    }
}
