// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { Streamers } from "../src/Streamers.sol";

contract InnerStreamerTest is Streamers {
    function support(address streamer, address token, uint256 amount) public {
        _addTokenSupport(streamer, token, amount);
    }

    function getStreamer(address streamer, address token) public view returns (address, uint256) {
        return getStreamerSupport(streamer, token);
    }

    function getTotalStreamer() public view returns (uint256) {
        return super.getStreamerCount();
    }
}

contract StreamersTest is Test {
    Streamers private streamers;
    InnerStreamerTest private innerStreamer;
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function setUp() public {
        streamers = new Streamers();
        innerStreamer = new InnerStreamerTest();
    }

    function testGetInvalidStreamer() public view {
        (address streamer, uint256 amount) = streamers.getStreamerSupport(address(this), ETH);
        assertEq(streamer, address(0), "Streamer should be zero address");
        assertEq(amount, 0, "Amount should be zero");
    }

    function testGetStreamerWithSupport() public {
        innerStreamer.support(address(this), ETH, 100);
        (address streamer, uint256 amount) = innerStreamer.getStreamer(address(this), ETH);
        assertEq(streamer, address(this), "Streamer should be this address");
        assertEq(amount, 100, "Amount should be 100");
    }

    function testGetStreamerCount() public {
        assertEq(innerStreamer.getTotalStreamer(), 0, "Total streamer should be zero");
        innerStreamer.support(address(this), ETH, 100);
        assertEq(innerStreamer.getTotalStreamer(), 1, "Total streamer should be one");

        innerStreamer.support(address(1), ETH, 100);
        assertEq(innerStreamer.getTotalStreamer(), 2, "Total streamer should be two");

        innerStreamer.support(address(2), ETH, 100);
        assertEq(innerStreamer.getTotalStreamer(), 3, "Total streamer should be three");
    }
}
