// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { IStreamFund } from "../src/StreamFund.sol";
import { console2 } from "forge-std/src/console2.sol";

contract ChangeFeeCollector is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        IStreamFund sf = IStreamFund(vm.envAddress("SF_CONTRACT"));
        address feeCollector = vm.envAddress("FEE_COLLECTOR");

        vm.startBroadcast(deployerPrivateKey);
        sf.setFeeCollector(feeCollector);
        vm.stopBroadcast();

        console2.log("Fee collector changed to: ", feeCollector);
    }
}
