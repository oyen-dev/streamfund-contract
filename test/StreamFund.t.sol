// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { StreamFund } from "../src/StreamFund.sol";
import { ERC20Mock } from "../src/ERC20Mock.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

contract EncoderDecoder {
    function encodePayload(string memory payload) public pure returns (bytes memory) {
        return abi.encode(payload);
    }

    function decodePayload(bytes memory encoded) public pure returns (string memory) {
        (string memory payload) = abi.decode(encoded, (string));
        return payload;
    }
}

contract StreamFundTest is Test {
    EncoderDecoder private encoderDecoder;
    StreamFund private streamFund;
    ERC20Mock private usdt;
    ERC20Mock private token;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    uint256 public constant CHAIN_ID = 4202;
    uint256 public constant FEE = 250; // 2.5%
    address private constant ADMIN = address(0x1);

    function setUp() public {
        encoderDecoder = new EncoderDecoder();
        streamFund = new StreamFund(ADMIN);
        usdt = new ERC20Mock(ADMIN, "Tether USD", "USDT", 10_000_000);
        token = new ERC20Mock(ADMIN, "Test Token", "TEST", 10_000_000);
    }

    function testSupportZeroETH() public {
        vm.expectRevert(
            abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "ETH amount cannot be zero")
        );

        streamFund.supportWithETH(address(0), "Hello");
    }

    function testSupportInvalidChainID() public {
        vm.chainId(1);
        vm.expectRevert(abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Invalid chain ID"));
        vm.startPrank(address(2));
        vm.deal(address(2), 10 ether);
        streamFund.supportWithETH{ value: 1 ether }(address(0), "Hello");
    }

    function testSupportWithETH() public {
        vm.chainId(4202);
        vm.startPrank(address(2));
        vm.deal(address(2), 10 ether);
        bytes memory data = encoderDecoder.encodePayload("Hello");
        uint256 amount = 1 ether;
        uint256 fee = (amount * FEE) / 10_000;
        uint256 netAmount = amount - fee;
        streamFund.supportWithETH{ value: amount }(address(3), data);
        assertEq(address(ADMIN).balance, fee, "Fee should be sent to the fee collector");
        assertEq(address(3).balance, netAmount, "Net amount should be sent to the streamer");
    }

    function testGetFeeCollector() public view {
        assertEq(streamFund.getFeeCollector(), ADMIN);
    }

    function testChangeFeeCollectorNotAdmin() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(2), DEFAULT_ADMIN_ROLE
            )
        );
        vm.startPrank(address(2));
        streamFund.setFeeCollector(address(3));
    }

    function testChangeFeeCollector() public {
        streamFund.setFeeCollector(address(2));
        assertEq(streamFund.getFeeCollector(), address(2), "Fee collector should be updated");
    }

    function testTokenAmountZero() public {
        vm.expectRevert(
            abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Token amount cannot be zero")
        );
        vm.startPrank(address(2));
        streamFund.supportWithToken(address(3), address(usdt), 0, "Hello");
    }

    function testTokenNotAllowed() public {
        bytes memory data = abi.encode("USDT");
        streamFund.addAllowedToken(address(usdt), data);

        vm.expectRevert(abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Token not allowed"));
        vm.startPrank(address(2));
        streamFund.supportWithToken(address(3), address(token), 1, "Hello");
    }

    function testInvalidChainID() public {
        bytes memory data = abi.encode("USDT");
        streamFund.addAllowedToken(address(usdt), data);

        vm.chainId(1);
        vm.expectRevert(abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Invalid chain ID"));
        vm.startPrank(address(2));
        streamFund.supportWithToken(address(3), address(usdt), 1, "Hello");
    }

    function testInsufficientAllowance() public {
        vm.startPrank(ADMIN);
        usdt.mintTo(address(2), 100e6);
        usdt.mintTo(address(this), 100e6);
        vm.stopPrank();

        uint8 usdtDecimals = usdt.decimals();
        string memory usdtSymbol = usdt.symbol();
        string memory usdtName = usdt.name();
        string memory params = "tether,https://assets.coingecko.com/coins/images/325/large/tether.png";
        bytes memory data = abi.encode(params);
        bytes memory emitData = abi.encode(address(usdt), usdtName, usdtSymbol, usdtDecimals, params);
        streamFund.addAllowedToken(address(usdt), data);
        assertEq(streamFund.getAllowedToken(address(usdt)), emitData, "USDT data should be the same");

        vm.chainId(4202);
        vm.startPrank(address(2));
        vm.expectRevert(abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Insufficient allowance"));
        streamFund.supportWithToken(address(3), address(usdt), 1, "Hello");
    }

    function testSupportWithToken() public {
        vm.startPrank(ADMIN);
        usdt.mintTo(address(2), 100e6);
        usdt.mintTo(address(this), 100e6);
        vm.stopPrank();

        uint8 usdtDecimals = usdt.decimals();
        string memory usdtSymbol = usdt.symbol();
        string memory usdtName = usdt.name();
        string memory params = "tether,https://assets.coingecko.com/coins/images/325/large/tether.png";
        bytes memory data = abi.encode(params);
        bytes memory emitData = abi.encode(address(usdt), usdtName, usdtSymbol, usdtDecimals, params);
        streamFund.addAllowedToken(address(usdt), data);
        assertEq(streamFund.getAllowedToken(address(usdt)), emitData, "USDT data should be the same");

        vm.chainId(4202);
        vm.startPrank(address(2));
        usdt.approve(address(streamFund), 100e6);
        data = encoderDecoder.encodePayload("Hello");
        uint256 amount = 100e6;
        uint256 fee = (amount * FEE) / 10_000;
        uint256 netAmount = amount - fee;

        streamFund.supportWithToken(address(3), address(usdt), amount, data);
        assertEq(usdt.balanceOf(address(3)), netAmount, "Net amount should be sent to the streamer");
        assertEq(usdt.balanceOf(address(ADMIN)), fee, "Fee should be sent to the fee collector");
    }

    function initStreamFund() public {
        vm.startPrank(ADMIN);
        StreamFund sf = new StreamFund(ADMIN);
        assertEq(sf.getFeeCollector(), ADMIN, "Fee collector should be the admin");
    }
}
