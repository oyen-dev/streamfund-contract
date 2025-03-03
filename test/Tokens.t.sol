// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { Tokens } from "../src/Tokens.sol";

contract TokensTest is Test {
    Tokens private tokens;
    uint256 private constant CHAIN_ID = 421_614;

    function setUp() public {
        tokens = new Tokens();
    }

    function testAddAllowedTokenZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token address cannot be zero"));
        bytes memory data = abi.encode("USDT");
        tokens.addAllowedToken(address(0), 6, data);
    }

    function testAddAllowedTokenZeroDecimals() public {
        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token decimals cannot be zero"));
        bytes memory data = abi.encode("USDT");
        tokens.addAllowedToken(address(1), 0, data);
    }

    function testAddAllowedTokenAlreadyExists() public {
        bytes memory data = abi.encode("USDT");
        tokens.addAllowedToken(address(1), 6, data);
        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token already exists"));
        tokens.addAllowedToken(address(1), 6, data);
    }

    function testAddAllowedToken() public {
        vm.expectEmit();
        uint8 decimals = 6;
        bytes memory data = abi.encode("USDT");
        emit Tokens.TokenAdded(address(1), CHAIN_ID, decimals, data);
        tokens.addAllowedToken(address(1), decimals, data);
    }

    function testRemoveAllowedTokenZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token address cannot be zero"));
        tokens.removeAllowedToken(address(0));
    }

    function testRemoveAllowedTokenDoesNotExist() public {
        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token does not exist"));
        tokens.removeAllowedToken(address(1));
    }

    function testRemoveAllowedToken() public {
        vm.expectEmit();
        uint8 decimals = 6;
        bytes memory data = abi.encode("USDT");
        emit Tokens.TokenAdded(address(1), CHAIN_ID, decimals, data);
        tokens.addAllowedToken(address(1), decimals, data);
        emit Tokens.TokenRemoved(address(1), CHAIN_ID);
        tokens.removeAllowedToken(address(1));
    }

    function testRemoveAllowedTokens() public {
        vm.expectEmit();
        bytes memory data = abi.encode("USDT");
        emit Tokens.TokenAdded(address(1), CHAIN_ID, 6, data);
        tokens.addAllowedToken(address(1), 6, data);

        emit Tokens.TokenAdded(address(2), CHAIN_ID, 6, data);
        tokens.addAllowedToken(address(2), 6, data);

        emit Tokens.TokenAdded(address(3), CHAIN_ID, 6, data);
        tokens.addAllowedToken(address(3), 6, data);

        emit Tokens.TokenRemoved(address(2), CHAIN_ID);
        tokens.removeAllowedToken(address(2));

        uint8 token1 = tokens.getAllowedToken(address(1));
        assertEq(token1, 6);

        uint8 token2 = tokens.getAllowedToken(address(2));
        assertEq(token2, 0);

        uint8 token3 = tokens.getAllowedToken(address(3));
        assertEq(token3, 6);
    }

    function testGetAllowedTokenZeroAddress() public view {
        uint8 token = tokens.getAllowedToken(address(0));
        assertEq(token, 0);
    }

    function testGetAllowedTokenExist() public {
        uint8 decimals = 6;
        bytes memory data = abi.encode("USDT");
        tokens.addAllowedToken(address(1), decimals, data);
        uint8 token = tokens.getAllowedToken(address(1));
        assertEq(token, decimals);
    }
}
