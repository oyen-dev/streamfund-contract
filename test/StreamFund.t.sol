// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { StreamFund } from "../src/StreamFund.sol";
import { ERC20Mock } from "../src/ERC20Mock.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

contract StreamFundTest is Test {
    StreamFund streamFund;
    ERC20Mock usdt;
    ERC20Mock token;
    address private constant ADMIN = address(0x1);
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    function setUp() public {
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

    function testSupportMessageLengthExceeded() public {
        vm.expectRevert(
            abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Message length exceeded")
        );

        vm.startPrank(address(2));
        vm.deal(address(2), 10 ether);
        streamFund.supportWithETH{ value: 1 ether }(
            address(0),
            "Hello, this is a very long message that exceeds the limit of 150 characters Hello, this is a very long message that exceeds the limit of 150 characterHello, this is a very long message that exceeds the"
        );
    }

    function testSupportInvalidChainID() public {
        vm.chainId(1);
        vm.expectRevert(abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Invalid chain ID"));
        vm.startPrank(address(2));
        vm.deal(address(2), 10 ether);
        streamFund.supportWithETH{ value: 1 ether }(address(0), "Hello");
    }

    function testSupportWithETH() public {
        vm.chainId(84_532);
        vm.startPrank(address(2));
        vm.deal(address(2), 10 ether);
        streamFund.supportWithETH{ value: 1 ether }(address(3), "Hello");
        assertEq(address(ADMIN).balance, 0.01 ether);
        assertEq(address(3).balance, 0.99 ether);
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
        assertEq(streamFund.getFeeCollector(), address(2));
    }

    function testTokenAmountZero() public {
        vm.expectRevert(
            abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Token amount cannot be zero")
        );
        vm.startPrank(address(2));
        streamFund.supportWithToken(address(3), address(usdt), 0, "Hello");
    }

    function testTokenNotAllowed() public {
        streamFund.addAllowedToken(address(usdt), 6, "USDT", "Tether USD");

        vm.expectRevert(abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Token not allowed"));
        vm.startPrank(address(2));
        streamFund.supportWithToken(address(3), address(token), 1, "Hello");
    }

    function testMessageLengthExceeded() public {
        streamFund.addAllowedToken(address(usdt), 6, "USDT", "Tether USD");

        vm.expectRevert(
            abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Message length exceeded")
        );
        vm.startPrank(address(2));
        streamFund.supportWithToken(
            address(3),
            address(usdt),
            1,
            "Hello, this is a very long message that exceeds the limit of 150 characters Hello, this is a very long message that exceeds the limit of 150 characterHello, this is a very long message that exceeds the"
        );
    }

    function testInvalidChainID() public {
        streamFund.addAllowedToken(address(usdt), 6, "USDT", "Tether USD");

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

        streamFund.addAllowedToken(address(usdt), 6, "USDT", "Tether USD");
        assertEq(streamFund.getAllowedToken(address(usdt)).symbol, "USDT");

        vm.chainId(84_532);
        vm.startPrank(address(2));
        vm.expectRevert(abi.encodeWithSelector(StreamFund.StreamFundValidationError.selector, "Insufficient allowance"));
        streamFund.supportWithToken(address(3), address(usdt), 1, "Hello");
    }

    function testSupportWithToken() public {
        vm.startPrank(ADMIN);
        usdt.mintTo(address(2), 100e6);
        usdt.mintTo(address(this), 100e6);
        vm.stopPrank();

        streamFund.addAllowedToken(address(usdt), 6, "USDT", "Tether USD");
        assertEq(streamFund.getAllowedToken(address(usdt)).symbol, "USDT");

        vm.chainId(84_532);
        vm.startPrank(address(2));
        usdt.approve(address(streamFund), 100e6);
        streamFund.supportWithToken(address(3), address(usdt), 100e6, "Hello");
        assertEq(usdt.balanceOf(address(3)), 99e6);
        assertEq(usdt.balanceOf(address(ADMIN)), 1e6);
    }
}
