// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.22 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { ERC20Mock } from "../src/ERC20Mock.sol";
import { console2 } from "forge-std/src/console2.sol";

contract DeployMockToken is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        string memory name = vm.envString("MOCK_TOKEN_NAME");
        string memory symbol = vm.envString("MOCK_TOKEN_SYMBOL");
        uint256 mintAmount = vm.envUint("MOCK_TOKEN_MINT_AMOUNT");

        vm.startBroadcast(deployerPrivateKey);
        ERC20Mock token = new ERC20Mock(deployer, name, symbol, mintAmount);
        vm.stopBroadcast();

        console2.log("Mock token name: ", name);
        console2.log("Mock token symbol: ", symbol);
        console2.log("Mock token deployed at: ", address(token));
    }
}
