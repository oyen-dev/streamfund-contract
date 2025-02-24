// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.20 <0.9.0;

import "forge-std/src/Test.sol";
import { Overmint1, Overmint1Attacker } from "../src/Overmint1.sol";

contract Overmint1Test is Test {
    Overmint1 overmint1;
    Overmint1Attacker attacker;

    function setUp() public {
        overmint1 = new Overmint1();
        attacker = new Overmint1Attacker(address(overmint1));
    }

    function test_attack() public {
        attacker.attack();
        assertEq(overmint1.success(address(attacker)), true);
    }
}
