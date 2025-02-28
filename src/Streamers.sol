// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.21 <0.9.0;

import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract Streamers {
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    uint256 private streamerCount;
    mapping(address streamer => mapping(address token => uint256)) private tokenSupport;
    EnumerableMap.AddressToUintMap private streamers;

    error StreamerValidationError(string message);

    event StreamerAdded(address indexed streamer);

    function getStreamerSupport(address streamer, address token) public view returns (address, uint256) {
        if (_isStreamerExists(streamer)) {
            return (streamer, tokenSupport[streamer][token]);
        }
        return (address(0), 0);
    }

    function getStreamerCount() public view returns (uint256) {
        return streamerCount;
    }

    function _addTokenSupport(address streamer, address token, uint256 amount) internal {
        if (!_isStreamerExists(streamer)) {
            _addStreamer(streamer);
        }
        tokenSupport[streamer][token] += amount;
    }

    function _addStreamer(address streamer) internal {
        streamers.set(streamer, streamerCount);
        streamerCount++;

        emit StreamerAdded(streamer);
    }

    function _isStreamerExists(address streamer) internal view returns (bool) {
        return streamers.contains(streamer);
    }
}
