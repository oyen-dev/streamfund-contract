// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.25 <0.9.0;

import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract Streamers {
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    struct TokenSupport {
        address token;
        uint256 total;
    }

    struct Streamer {
        address streamer;
        TokenSupport[] cumulative;
    }

    uint256 public streamerCount;
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    Streamer[] internal registeredStreamers;
    EnumerableMap.AddressToUintMap private streamers;

    error StreamerValidationError(string message);

    event StreamerAdded(address indexed streamer);

    function register() public {
        if (streamers.contains(msg.sender)) {
            revert StreamerValidationError("Streamer already registered");
        }

        streamers.set(msg.sender, streamerCount);
        registeredStreamers.push();
        registeredStreamers[streamerCount].streamer = msg.sender;
        streamerCount += 1;
        _addTokenSupport(msg.sender, ETH, 0);

        emit StreamerAdded(msg.sender);
    }

    function getStreamer(address streamer) public view returns (address, TokenSupport[] memory) {
        if (_isStreamerExists(streamer)) {
            uint256 index = _getStreamerIndex(streamer);
            Streamer memory details = registeredStreamers[index];
            return (streamer, details.cumulative);
        }
        return (address(0), new TokenSupport[](0));
    }

    function _addTokenSupport(address streamer, address token, uint256 amount) internal {
        if (!_isStreamerExists(streamer)) {
            revert StreamerValidationError("Streamer not registered");
        }
        uint256 index = _getStreamerIndex(streamer);

        for (uint256 i = 0; i < registeredStreamers[index].cumulative.length;) {
            if (registeredStreamers[index].cumulative[i].token == token) {
                registeredStreamers[index].cumulative[i].total += amount;
                return;
            }
            unchecked {
                i++;
            }
        }
        TokenSupport memory newToken = TokenSupport(token, amount);
        registeredStreamers[index].cumulative.push(newToken);
    }

    function _isStreamerExists(address streamer) internal view returns (bool) {
        return streamers.contains(streamer);
    }

    function _getStreamerIndex(address streamer) internal view returns (uint256) {
        return streamers.get(streamer);
    }
}
