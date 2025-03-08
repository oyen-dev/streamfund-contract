// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { IStreamFund } from "../src/StreamFund.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { console2 } from "forge-std/src/console2.sol";

contract SupportWithETH is Script {
    function run() public {
        uint256 viewerPK = vm.envUint("VIEWER_PK");

        IStreamFund sf = IStreamFund(vm.envAddress("SF_CONTRACT"));
        address streamer = vm.envAddress("STREAMER_ADDRESS");
        bytes memory data = abi.encode(vm.envString("SUPPORT_PARAMS"));

        vm.startBroadcast(viewerPK);
        sf.supportWithETH{ value: 0.001 ether }(streamer, data);
        vm.stopBroadcast();

        console2.log("Successfully support to ", streamer);
    }
}
