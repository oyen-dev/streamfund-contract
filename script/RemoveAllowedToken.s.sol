// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { IStreamFund } from "../src/StreamFund.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { console2 } from "forge-std/src/console2.sol";

contract RemoveAllowedToken is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        IStreamFund sf = IStreamFund(vm.envAddress("SF_CONTRACT"));
        IERC20Metadata token = IERC20Metadata(vm.envAddress("TOKEN_ADDRESS"));
        string memory tokenName = token.name();

        vm.startBroadcast(deployerPrivateKey);
        sf.removeAllowedToken(address(token));
        vm.stopBroadcast();

        console2.log("Token removed from StreamFund: ", tokenName);
    }
}
