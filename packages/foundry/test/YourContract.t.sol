// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/Trybe.sol";

contract YourContractTest is Test {
    Trybe public yourContract;

    function setUp() public {
        yourContract = new Trybe(vm.addr(1));
    }
}
