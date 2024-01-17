// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SupraOracleToken} from "../src/Token/SupraOracleToken.sol";

contract SupraOraclesTokenTest is Test {
    SupraOracleToken public contractAddress;

    function setUp() public {
        contractAddress = new SupraOracleToken(address(1));
    }

    function test_Owner() public view {
        assert(contractAddress.owner() == address(1));
    }

    function test_decimals() public view {
        assert(contractAddress.decimals() == 18);
    }

    function test_Name() public {
        assertEq(contractAddress.name(), "SupraOracle Token");
    }

    function test_Symbol() public {
        assertEq(contractAddress.symbol(), "SOT");
    }

    function test_Mint(uint256 amount, address testAddr) public {
        vm.assume(testAddr != address(0));
        vm.prank(address(1));
        contractAddress.mint(testAddr, amount);
        assertEq(contractAddress.balanceOf(testAddr), amount);
    }

    function testFail_OtherMint(uint256 amount, address testAddr) public {
        vm.prank(address(2));
        contractAddress.mint(testAddr, amount);
        assertEq(contractAddress.balanceOf(testAddr), amount);
    }

    function test_Transfer(address to, uint256 amount) public {
        vm.assume(to != address(0));
        vm.prank(address(1));
        contractAddress.mint(address(2), amount);
        vm.prank(address(2));
        assert(contractAddress.transfer(to, amount));
        assert(contractAddress.balanceOf(to) == amount);
    }
}
