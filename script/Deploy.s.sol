// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.25 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { StreamFund } from "../src/StreamFund.sol";

contract Deploy is Script {
    function run() public {
        vm.createSelectFork("base-sepolia");
        vm.startBroadcast();
        new StreamFund(0x8844a5958178f0788a994ed19448e76a1f493248);
        vm.stopBroadcast();
    }
}
