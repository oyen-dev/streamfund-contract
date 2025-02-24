// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { Streamers } from "../src/Streamers.sol";

contract Donate is Streamers {
    function regis() external {
        register();
    }

    function donate(address streamer, address token, uint256 amount) external {
        _addTokenSupport(streamer, token, amount);
    }

    function getStream(address streamer) external view returns (address, TokenSupport[] memory) {
        return getStreamer(streamer);
    }
}

contract StreamersTest is Test {
    Streamers streamers;
    Donate donate;
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function setUp() public {
        streamers = new Streamers();
        donate = new Donate();
    }

    function testGetUnregisteredStreamer() public view {
        address unregisteredStreamer = address(0x456);
        (address registeredStreamer, Streamers.TokenSupport[] memory tokenSupport) =
            streamers.getStreamer(unregisteredStreamer);
        assertEq(registeredStreamer, address(0));
        assertEq(tokenSupport.length, 0);
    }

    function testFailAlreadyRegistered() public {
        streamers.register();
        vm.expectRevert("Streamer already registered");
        streamers.register();
    }

    function testRegister() public {
        streamers.register();
        (address streamer,) = streamers.getStreamer(address(this));
        assertEq(streamer, address(this));
    }

    function testGetInvalidStreamer() public view {
        (address streamer,) = streamers.getStreamer(address(this));
        assertEq(streamer, address(0));
    }

    function testFailAddSupportToInvalidStreamer() public {
        vm.expectRevert("Streamer not registered");
        donate.donate(address(this), address(this), 100);
    }

    function testAddSupport() public {
        donate.regis();
        donate.donate(address(this), address(1), 100);
        donate.donate(address(this), ETH, 200);
        (address user, Streamers.TokenSupport[] memory cumulative) = donate.getStream(address(this));
        assertEq(user, address(this));
        assertEq(cumulative.length, 2);
    }
}
