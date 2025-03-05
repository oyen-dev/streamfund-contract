// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { Tokens } from "../src/Tokens.sol";
import { ERC20Mock } from "../src/ERC20Mock.sol";
import { console2 } from "forge-std/src/console2.sol";

contract TokensTest is Test {
    uint256 private constant CHAIN_ID = 421_614;
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
        address usdtAddress = address(usdt);
        string memory usdtSymbol = usdt.symbol();
        string memory usdtCoinGecko = "tether";
        string memory usdtLogo = "https://assets.coingecko.com/coins/images/325/large/tether.png";
        bytes memory data = abi.encode(usdtAddress, usdtSymbol, usdtDecimals, usdtCoinGecko, usdtLogo);

        tokens.addAllowedToken(usdtAddress, data);
        vm.expectRevert(abi.encodeWithSelector(Tokens.TokenValidationError.selector, "Token already exists"));
        tokens.addAllowedToken(usdtAddress, data);
    }

    function testAddAllowedToken() public {
        vm.expectEmit();
        uint8 usdtDecimals = usdt.decimals();
        address usdtAddress = address(usdt);
        string memory usdtSymbol = usdt.symbol();
        string memory usdtCoinGecko = "tether";
        string memory usdtLogo = "https://assets.coingecko.com/coins/images/325/large/tether.png";
        bytes memory data = abi.encode(usdtAddress, usdtSymbol, usdtDecimals, usdtCoinGecko, usdtLogo);

        emit Tokens.TokenAdded(usdtAddress, CHAIN_ID, usdtDecimals, data);
        tokens.addAllowedToken(usdtAddress, data);
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
        address usdtAddress = address(usdt);
        string memory usdtSymbol = usdt.symbol();
        string memory usdtCoinGecko = "tether";
        string memory usdtLogo = "https://assets.coingecko.com/coins/images/325/large/tether.png";
        bytes memory data = abi.encode(usdtAddress, usdtSymbol, usdtDecimals, usdtCoinGecko, usdtLogo);

        emit Tokens.TokenAdded(usdtAddress, CHAIN_ID, usdtDecimals, data);
        tokens.addAllowedToken(usdtAddress, data);
        emit Tokens.TokenRemoved(usdtAddress, CHAIN_ID);
        tokens.removeAllowedToken(usdtAddress);
    }

    // function testRemoveAllowedTokens() public {
    //     vm.expectEmit();
    //     uint8 usdtDecimals = usdt.decimals();
    //     address usdtAddress = address(usdt);
    //     string memory usdtSymbol = usdt.symbol();
    //     string memory usdtCoinGecko = "tether";
    //     string memory usdtLogo = "https://assets.coingecko.com/coins/images/325/large/tether.png";
    //     bytes memory usdtData = abi.encode(usdtAddress, usdtSymbol, usdtDecimals, usdtCoinGecko, usdtLogo);

    //     uint8 usdcDecimals = usdc.decimals();
    //     address usdcAddress = address(usdc);
    //     string memory usdcSymbol = usdc.symbol();
    //     string memory usdcCoinGecko = "usd-coin";
    //     string memory usdcLogo = "https://assets.coingecko.com/coins/images/325/large/usd-coin.png";
    //     bytes memory usdcData = abi.encode(usdcAddress, usdcSymbol, usdcDecimals, usdcCoinGecko, usdcLogo);

    //     emit Tokens.TokenAdded(usdtAddress, CHAIN_ID, usdtDecimals, usdtData);
    //     tokens.addAllowedToken(usdtAddress, usdtData);

    //     emit Tokens.TokenAdded(usdcAddress, CHAIN_ID, usdcDecimals, usdcData);
    //     tokens.addAllowedToken(usdcAddress, usdcData);

    //     emit Tokens.TokenRemoved(usdcAddress, CHAIN_ID);
    //     tokens.removeAllowedToken(usdcAddress);

    //     bytes memory usdtD = tokens.getAllowedToken(address(1));
    //     console2.logBytes(usdtData);
    //     console2.logBytes(usdtD);
    //     assertEq(usdtD, usdtData);

    //     bytes memory usdcD = tokens.getAllowedToken(address(2));
    //     assertEq(usdcD, "0x");
    // }

    function testGetAllowedTokenZeroAddress() public view {
        bytes memory token = tokens.getAllowedToken(address(0));
        assertEq(token, "");
    }

    // function testGetAllowedTokenExist() public {
    //     bytes memory data = abi.encode("USDT");
    //     tokens.addAllowedToken(address(1), data);
    //     bytes memory token = tokens.getAllowedToken(address(1));
    //     assertEq(token, data);
    // }
}
