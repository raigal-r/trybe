// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

interface ITrybe {
    function isMember(
        address account,
        uint256 _tokenId
    ) external view returns (bool);
}
