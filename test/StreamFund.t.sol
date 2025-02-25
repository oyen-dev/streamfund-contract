// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { StreamFund } from "../src/StreamFund.sol";

contract StreamFundTest is Test {
    StreamFund streamFund;

    function setUp() public {
        streamFund = new StreamFund(address(1000));
    }

    function testFailSupportZeroETH() public {
        vm.expectRevert("ETH amount cannot be zero");

        streamFund.supportWithETH(address(0), "Hello");
    }

    function testFailSupportMessageLengthExceeded() public {
        vm.expectRevert("Message length exceeded");

        streamFund.supportWithETH(
            address(0),
            "Hello, this is a very long message that exceeds the limit of 150 characters Hello, this is a very long message that exceeds the limit of 150 characterHello, this is a very long message that exceeds the"
        );
    }

    function testFailSupportInvalidChainID() public {
        vm.chainId(1);
        vm.expectRevert("Invalid chain ID");

        streamFund.supportWithETH(address(0), "Hello");
    }
}
