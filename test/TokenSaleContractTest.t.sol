// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSaleContract} from "../src/SaleContract/TokenSaleContract.sol";
import {SupraOracleToken} from "../src/Token/SupraOracleToken.sol";
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

    function testChangePreSaleStatus() public {
        tokenSale.changePreSaleStatus(true);
        assertTrue(tokenSale.isPreSaleActive());
        assertFalse(tokenSale.isPublicSaleActive());

        tokenSale.changePreSaleStatus(false);
        assertFalse(tokenSale.isPreSaleActive());
        assertFalse(tokenSale.isPublicSaleActive());
    }

    function testChangePublicSaleStatus() public {
        tokenSale.changePublicSaleStatus(true);
        assertFalse(tokenSale.isPreSaleActive());
        assertTrue(tokenSale.isPublicSaleActive());

        tokenSale.changePublicSaleStatus(false);
        assertFalse(tokenSale.isPreSaleActive());
        assertFalse(tokenSale.isPublicSaleActive());
    }

    function testBuyTokens() public {
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(true);
        vm.stopPrank();
        vm.deal(address(0x123), 20 ether);
        vm.startPrank(address(0x123));
        tokenSale.buyTokens{value: 10 ether}();
        assertTrue(tokenSale.isPreSaleActive());
        assertEq(tokenSale.contributions(address(0x123)), 10 ether);
        assertEq(token.balanceOf(address(0x123)), 100 ether);
        vm.stopPrank();
    }

    function testDistributeTokens() public {
        vm.startPrank(address(this));
        tokenSale.distributeTokens(address(this), 100 * (10 ** token.decimals()));
        assertEq(token.balanceOf(address(this)), 100 * (10 ** token.decimals()));
        vm.stopPrank();
    }

    function testRefund() public {
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(true);
        vm.deal(address(0x123), 20 ether);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        tokenSale.buyTokens{value: 15 ether}();
        assertTrue(tokenSale.isPreSaleActive());
        assertEq(tokenSale.contributions(address(0x123)), 15 ether);
        assertEq(token.balanceOf(address(0x123)), 150 ether);
        vm.stopPrank();
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(false);
        tokenSale.changePublicSaleStatus(true);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        token.approve(address(tokenSale), 150 ether);
        tokenSale.refund(15 ether);
        assertEq(tokenSale.contributions(address(0x123)), 0);
        assertEq(token.balanceOf(address(0x123)), 0);
        vm.stopPrank();
    }
}
