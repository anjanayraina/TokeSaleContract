// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSaleContract} from "../../src/SaleContract/TokenSaleContract.sol";
import {SupraOracleToken} from "../../src/Token/SupraOracleToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSaleContractTest is Test {
    TokenSaleContract public tokenSale;
    SupraOracleToken public token;

    function setUp() public {
        token = new SupraOracleToken(address(this));
        tokenSale = new TokenSaleContract(IERC20(token), address(this));
        vm.startPrank(address(this));
        token.mint(address(tokenSale), 1000 * (10 ** token.decimals()));
    }

    function testInitialState() public {
        assertFalse(tokenSale.isPreSaleActive());
        assertFalse(tokenSale.isPublicSaleActive());
    }

    function testFail_ChangePreSaleStatus(address callerAddress) public {
        vm.assume(callerAddress != address(this));
        vm.startPrank(callerAddress);
        tokenSale.changePreSaleStatus(true);
        assertTrue(tokenSale.isPreSaleActive());
        assertFalse(tokenSale.isPublicSaleActive());
        tokenSale.changePreSaleStatus(false);
        assertFalse(tokenSale.isPreSaleActive());
        assertFalse(tokenSale.isPublicSaleActive());
        vm.stopPrank();
    }

    function testFail_ChangePublicSaleStatus(address callerAddress) public {
        vm.assume(callerAddress != address(this));
        vm.startPrank(callerAddress);
        tokenSale.changePublicSaleStatus(true);
        assertFalse(tokenSale.isPreSaleActive());
        assertTrue(tokenSale.isPublicSaleActive());

        tokenSale.changePublicSaleStatus(false);
        assertFalse(tokenSale.isPreSaleActive());
        assertFalse(tokenSale.isPublicSaleActive());
        vm.stopPrank();
    }

    function test_PreSaleBuyTokens(uint256 amount) public {
        vm.assume(amount < 100 ether);

        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(true);
        vm.stopPrank();
        vm.deal(address(0x123), amount);
        vm.startPrank(address(0x123));
        tokenSale.buyTokens{value: amount}();
        assertTrue(tokenSale.isPreSaleActive());
        assertEq(tokenSale.contributions(address(0x123)), amount);
        assertEq(token.balanceOf(address(0x123)), 10 * amount);
        vm.stopPrank();
    }

    function test_PublicSaleBuyTokens(uint256 amount) public {
        vm.assume(amount < 200 ether);
        vm.startPrank(address(this));
        tokenSale.changePublicSaleStatus(true);
        token.mint(address(tokenSale), amount * (10 ** token.decimals()));
        vm.stopPrank();
        vm.deal(address(0x123), amount);
        vm.startPrank(address(0x123));
        tokenSale.buyTokens{value: amount}();
        assertTrue(tokenSale.isPublicSaleActive());
        assertEq(tokenSale.contributions(address(0x123)), amount);
        assertEq(token.balanceOf(address(0x123)), 10 * amount);
        vm.stopPrank();
    }

    function testDistributeTokens(uint256 amount, address to) public {
        vm.assume(to != address(0));
        vm.assume(to != address(this));
        vm.assume(amount != 0);
        vm.assume(amount < type(uint128).max);
        vm.startPrank(address(this));
        token.mint(address(tokenSale), amount);
        tokenSale.distributeTokens(to, amount);
        assertEq(token.balanceOf(to), amount);
        vm.stopPrank();
    }
}
