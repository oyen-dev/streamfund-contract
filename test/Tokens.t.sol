// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { Tokens } from "../src/Tokens.sol";

contract TokensTest is Test {
    Tokens private tokens;
    uint256 private constant CHAIN_ID = 84_532;

    function setUp() public {
        tokens = new Tokens();
    }

    function testAddAllowedTokenZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token address cannot be zero"));
        tokens.addAllowedToken(address(0), 6, "USDT", "Tether USD");
    }

    function testAddAllowedTokenZeroDecimals() public {
        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token decimals cannot be zero"));
        tokens.addAllowedToken(address(1), 0, "USDT", "Tether USD");
    }

    function testAddAllowedTokenEmptySymbol() public {
        vm.expectRevert(
            abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token symbol or name cannot be empty")
        );
        tokens.addAllowedToken(address(1), 6, "", "Tether USD");
    }

    function testAddAllowedTokenEmptyName() public {
        vm.expectRevert(
            abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token symbol or name cannot be empty")
        );
        tokens.addAllowedToken(address(1), 6, "USDT", "");
    }

    function testAddAllowedTokenAlreadyExists() public {
        tokens.addAllowedToken(address(1), 6, "USDT", "Tether USD");
        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token already exists"));
        tokens.addAllowedToken(address(1), 6, "USDT", "Tether USD");
    }

    function testAddAllowedToken() public {
        vm.expectEmit();
        uint8 decimals = 6;
        string memory symbol = "USDT";
        string memory name = "Tether USD";
        emit Tokens.TokenAdded(address(1), decimals, CHAIN_ID, symbol, name);
        tokens.addAllowedToken(address(1), decimals, symbol, name);
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
        string memory symbol = "USDT";
        string memory name = "Tether USD";
        emit Tokens.TokenAdded(address(1), decimals, CHAIN_ID, symbol, name);
        tokens.addAllowedToken(address(1), decimals, symbol, name);
        emit Tokens.TokenRemoved(address(1), CHAIN_ID);
        tokens.removeAllowedToken(address(1));
    }

    function testRemoveAllowedTokens() public {
        vm.expectEmit();
        emit Tokens.TokenAdded(address(1), 6, CHAIN_ID, "USDT", "Tether USD");
        tokens.addAllowedToken(address(1), 6, "USDT", "Tether USD");

        emit Tokens.TokenAdded(address(2), 6, CHAIN_ID, "USDC", "USD Coin");
        tokens.addAllowedToken(address(2), 6, "USDC", "USD Coin");

        emit Tokens.TokenAdded(address(3), 6, CHAIN_ID, "DAI", "Dai Stablecoin");
        tokens.addAllowedToken(address(3), 6, "DAI", "Dai Stablecoin");

        emit Tokens.TokenRemoved(address(2), CHAIN_ID);
        tokens.removeAllowedToken(address(2));

        Tokens.AllowedToken memory token1 = tokens.getAllowedToken(address(1));
        assertEq(token1.decimals, 6);
        assertEq(token1.symbol, "USDT");
        assertEq(token1.name, "Tether USD");

        Tokens.AllowedToken memory token2 = tokens.getAllowedToken(address(2));
        assertEq(token2.decimals, 0);
        assertEq(token2.symbol, "");
        assertEq(token2.name, "");

        Tokens.AllowedToken memory token3 = tokens.getAllowedToken(address(3));
        assertEq(token3.decimals, 6);
        assertEq(token3.symbol, "DAI");
        assertEq(token3.name, "Dai Stablecoin");
    }

    function testGetAllowedTokenZeroAddress() public view {
        Tokens.AllowedToken memory token = tokens.getAllowedToken(address(0));
        assertEq(token.decimals, 0);
        assertEq(token.symbol, "");
        assertEq(token.name, "");
    }

    function testGetAllowedTokenExist() public {
        uint8 decimals = 6;
        string memory symbol = "USDT";
        string memory name = "Tether USD";
        tokens.addAllowedToken(address(1), decimals, symbol, name);
        Tokens.AllowedToken memory token = tokens.getAllowedToken(address(1));
        assertEq(token.decimals, decimals);
        assertEq(token.symbol, symbol);
        assertEq(token.name, name);
    }
}
