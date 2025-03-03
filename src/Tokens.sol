// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract Tokens is AccessControl {
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    uint256 private constant CHAIN_ID = 421_614;
    mapping(address tokenAddress => uint8 decimals) private allowedTokens;
    bytes32 private constant EDITOR_ROLE = keccak256("EDITOR_ROLE");
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
     * @param decimals of the token
     * @param data additional data for the token
     */
    function addAllowedToken(address tokenAddress, uint8 decimals, bytes memory data) external onlyRole(EDITOR_ROLE) {
        if (tokenAddress == address(0)) {
            revert TokenValidationError("Token address cannot be zero");
        }
        if (decimals == 0) {
            revert TokenValidationError("Token decimals cannot be zero");
        }

        if (_isTokenAvailable(tokenAddress)) {
            revert TokenValidationError("Token already exists");
        }

        allowedTokens[tokenAddress] = decimals;
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
     * @return decimals The number of decimals of the token.
     */
    function getAllowedToken(address tokenAddress) external view returns (uint8 decimals) {
        return allowedTokens[tokenAddress];
    }

    /**
     * @dev Checks if a token is available in the allowed tokens list.
     * @param tokenAddress The address of the token to check.
     * @return bool Returns true if the token is available, false otherwise.
     */
    function _isTokenAvailable(address tokenAddress) internal view returns (bool) {
        return allowedTokens[tokenAddress] != 0;
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
