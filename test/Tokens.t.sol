// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { Tokens } from "../src/Tokens.sol";
import { ERC20Mock } from "../src/ERC20Mock.sol";

contract TokensTest is Test {
    uint256 private constant CHAIN_ID = 4202;
    Tokens private tokens;
    ERC20Mock private usdt;
    ERC20Mock private usdc;
    address private constant ADMIN = address(0x1);

    function setUp() public {
        tokens = new Tokens();
        usdt = new ERC20Mock(ADMIN, "Tether USD", "USDT", 100_000_000);
        usdc = new ERC20Mock(ADMIN, "USD Coin", "USDC", 100_000_000);
    }

    function testAddAllowedTokenZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token address cannot be zero"));
        bytes memory data = abi.encode("USDT");
        tokens.addAllowedToken(address(0), data);
    }

    function testAddAllowedTokenAlreadyExists() public {
        uint8 usdtDecimals = usdt.decimals();
        string memory usdtSymbol = usdt.symbol();
        string memory usdtName = usdt.name();
        string memory params = "tether,https://assets.coingecko.com/coins/images/325/large/tether.png";
        bytes memory data = abi.encode(params);
        bytes memory emitData = abi.encode(address(usdt), usdtName, usdtSymbol, usdtDecimals, params);
        emit Tokens.TokenAdded(address(usdt), CHAIN_ID, usdtDecimals, emitData);
        tokens.addAllowedToken(address(usdt), data);

        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token already exists"));
        tokens.addAllowedToken(address(usdt), data);
    }

    function testAddAllowedToken() public {
        vm.expectEmit();
        uint8 usdtDecimals = usdt.decimals();
        string memory usdtSymbol = usdt.symbol();
        string memory usdtName = usdt.name();
        string memory params = "tether,https://assets.coingecko.com/coins/images/325/large/tether.png";
        bytes memory data = abi.encode(params);
        bytes memory emitData = abi.encode(address(usdt), usdtName, usdtSymbol, usdtDecimals, params);

        emit Tokens.TokenAdded(address(usdt), CHAIN_ID, usdtDecimals, emitData);
        tokens.addAllowedToken(address(usdt), data);

        bytes memory token = tokens.getAllowedToken(address(usdt));
        assertEq(token, emitData, "USDT data should be the same");
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
        uint8 usdtDecimals = usdt.decimals();
        string memory usdtSymbol = usdt.symbol();
        string memory usdtName = usdt.name();
        string memory params = "tether,https://assets.coingecko.com/coins/images/325/large/tether.png";
        bytes memory data = abi.encode(params);
        bytes memory emitData = abi.encode(address(usdt), usdtName, usdtSymbol, usdtDecimals, params);

        emit Tokens.TokenAdded(address(usdt), CHAIN_ID, usdtDecimals, emitData);
        tokens.addAllowedToken(address(usdt), data);
        emit Tokens.TokenRemoved(address(usdt), CHAIN_ID);
        tokens.removeAllowedToken(address(usdt));

        bytes memory token = tokens.getAllowedToken(address(usdt));
        assertEq(token, "", "USDT data should be empty");
    }

    function testRemoveAllowedTokens() public {
        vm.expectEmit();
        uint8 usdtDecimals = usdt.decimals();
        string memory usdtSymbol = usdt.symbol();
        string memory usdtName = usdt.name();
        string memory usdtParams = "tether,https://assets.coingecko.com/coins/images/325/large/tether.png";
        bytes memory usdtData = abi.encode(usdtParams);
        bytes memory usdtEmitData = abi.encode(address(usdt), usdtName, usdtSymbol, usdtDecimals, usdtParams);

        uint8 usdcDecimals = usdt.decimals();
        string memory usdcSymbol = usdt.symbol();
        string memory usdcName = usdt.name();
        string memory usdcParams = "tether,https://assets.coingecko.com/coins/images/325/large/usd-coin.png";
        bytes memory usdcData = abi.encode(usdcParams);
        bytes memory usdcEmitData = abi.encode(address(usdt), usdcName, usdcSymbol, usdtDecimals, usdcParams);

        emit Tokens.TokenAdded(address(usdt), CHAIN_ID, usdtDecimals, usdtEmitData);
        tokens.addAllowedToken(address(usdt), usdtData);

        emit Tokens.TokenAdded(address(usdc), CHAIN_ID, usdcDecimals, usdcEmitData);
        tokens.addAllowedToken(address(usdc), usdcData);

        emit Tokens.TokenRemoved(address(usdc), CHAIN_ID);
        tokens.removeAllowedToken(address(usdc));

        bytes memory usdtD = tokens.getAllowedToken(address(usdt));
        assertEq(usdtD, usdtEmitData, "USDT data should be the same");

        bytes memory usdcD = tokens.getAllowedToken(address(usdc));
        assertEq(usdcD, "", "USDC data should be empty");
    }

    function testGetAllowedTokenZeroAddress() public view {
        bytes memory token = tokens.getAllowedToken(address(0));
        assertEq(token, "", "Token data should be empty");
    }

    function testGetAllowedTokenDoesNotExist() public view {
        bytes memory token = tokens.getAllowedToken(address(1));
        assertEq(token, "", "Token data should be empty");
    }

    function testGetAllowedTokenExist() public {
        vm.expectEmit();
        uint8 usdtDecimals = usdt.decimals();
        string memory usdtSymbol = usdt.symbol();
        string memory usdtName = usdt.name();
        string memory params = "tether,https://assets.coingecko.com/coins/images/325/large/tether.png";
        bytes memory data = abi.encode(params);
        bytes memory emitData = abi.encode(address(usdt), usdtName, usdtSymbol, usdtDecimals, params);

        emit Tokens.TokenAdded(address(usdt), CHAIN_ID, usdtDecimals, emitData);
        tokens.addAllowedToken(address(usdt), data);

        bytes memory token = tokens.getAllowedToken(address(usdt));
        assertEq(token, emitData, "USDT data should be the same");
    }
}
