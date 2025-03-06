// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { StreamFund } from "../src/StreamFund.sol";
import { console2 } from "forge-std/src/console2.sol";

contract Deploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        StreamFund sf = new StreamFund(deployer);
        vm.stopBroadcast();

        console2.log("StreamFund deployed at: ", address(sf));
    }
}
