// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.20 <0.9.0;

import "forge-std/src/Test.sol";
import { Overmint2, Overmint2Attacker } from "../src/Overmint2.sol";

contract Overmint2Test is Test {
    Overmint2 overmint2;
    Overmint2Attacker attacker;

    function setUp() public {
        overmint2 = new Overmint2();
        attacker = new Overmint2Attacker(address(overmint2), address(1));
    }

    function test_attack() public {
        attacker.attack();

        vm.startPrank(address(1));
        assertEq(overmint2.success(), true);
        vm.stopPrank();
    }
}
