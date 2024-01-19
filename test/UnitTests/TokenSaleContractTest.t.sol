// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {TokenSaleContract} from "../../src/SaleContract/TokenSaleContract.sol";
import {SupraOracleToken} from "../../src/Token/SupraOracleToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSaleContractTest is Test {
    TokenSaleContract public tokenSale;
    SupraOracleToken public token;

    error SaleNotActive();
    error PreSaleCapExcedded();
    error PostSaleCapExcedded();
    error PreSaleStillActive();
    error BalanceHigherThanMinimmum();

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

    function test_BuyTokens() public {
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

    function test_BuyTokensSaleInactive() public {
        vm.startPrank(address(this));
        vm.stopPrank();
        vm.deal(address(0x123), 20 ether);
        vm.startPrank(address(0x123));
        vm.expectRevert(SaleNotActive.selector);
        tokenSale.buyTokens{value: 10 ether}();
        vm.stopPrank();
    }

    function test_BuyTokensPreSaleCapExcedded() public {
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(true);
        vm.stopPrank();
        vm.deal(address(0x123), 20 ether);
        vm.startPrank(address(0x123));
        vm.deal(address(0x123), 200 ether);
        vm.expectRevert(PreSaleCapExcedded.selector);
        tokenSale.buyTokens{value: 101 ether}();
        vm.stopPrank();
    }

    function test_BuyTokensPublicSaleCapExcedded() public {
        vm.startPrank(address(this));
        tokenSale.changePublicSaleStatus(true);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        vm.deal(address(0x123), 300 ether);
        vm.expectRevert(PostSaleCapExcedded.selector);
        tokenSale.buyTokens{value: 201 ether}();
        vm.stopPrank();
    }

    function test_DistributeTokens() public {
        vm.startPrank(address(this));
        tokenSale.distributeTokens(address(this), 100 * (10 ** token.decimals()));
        assertEq(token.balanceOf(address(this)), 100 * (10 ** token.decimals()));
        vm.stopPrank();
    }

    function test_RefundPreSaleActive() public {
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(true);
        vm.deal(address(0x123), 20 ether);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        tokenSale.buyTokens{value: 5 ether}();
        assertTrue(tokenSale.isPreSaleActive());
        assertEq(tokenSale.contributions(address(0x123)), 5 ether);
        assertEq(token.balanceOf(address(0x123)), 50 ether);
        vm.stopPrank();
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(false);
        tokenSale.changePublicSaleStatus(true);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        token.approve(address(tokenSale), 150 ether);
        tokenSale.refund(5 ether);
        assertEq(tokenSale.contributions(address(0x123)), 0);
        assertEq(token.balanceOf(address(0x123)), 0);
        vm.stopPrank();
    }

    function test_RefundPreSaleStillActive() public {
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
        vm.stopPrank();
        vm.startPrank(address(0x123));
        token.approve(address(tokenSale), 150 ether);
        vm.expectRevert(PreSaleStillActive.selector);
        tokenSale.refund(15 ether);
        vm.stopPrank();
    }

    function test_RefundPublicSaleInActiveBalanceHigher() public {
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(true);
        vm.deal(address(0x123), 200 ether);
        token.mint(address(0x123), 300 ether);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        tokenSale.buyTokens{value: 30 ether}();
        vm.stopPrank();
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(false);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        token.approve(address(tokenSale), 300 ether);
        vm.expectRevert(BalanceHigherThanMinimmum.selector);
        tokenSale.refund(30 ether);
        vm.stopPrank();
    }

    function test_RefundPublicSaleActive() public {
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(true);
        vm.deal(address(0x123), 200 ether);
        token.mint(address(tokenSale), 1000 * (10 ** token.decimals()));
        token.mint(address(0x123), 300 ether);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        tokenSale.buyTokens{value: 30 ether}();
        vm.stopPrank();
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(false);
        tokenSale.changePublicSaleStatus(true);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        token.approve(address(tokenSale), 300 ether);
        uint256 balanceBefore = address(0x123).balance;
        vm.expectRevert(BalanceHigherThanMinimmum.selector);
        tokenSale.refund(30 ether);
        vm.stopPrank();
    }

    function test_RefundPublicSaleActive2() public {
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(true);
        vm.deal(address(0x123), 200 ether);
        token.mint(address(tokenSale), 1000 * (10 ** token.decimals()));
        token.mint(address(0x123), 300 ether);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        tokenSale.buyTokens{value: 100 wei}();
        vm.stopPrank();
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(false);
        tokenSale.changePublicSaleStatus(true);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        token.approve(address(tokenSale), 300 ether);
        uint256 balanceBefore = address(0x123).balance;
        tokenSale.refund(10 wei);
        assertEq(address(0x123).balance, balanceBefore + 10 wei);
        vm.stopPrank();
    }

    function test_RefundPublicSaleActive3() public {
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(true);
        vm.deal(address(0x123), 200 ether);
        token.mint(address(tokenSale), 1000 * (10 ** token.decimals()));
        token.mint(address(0x123), 300 ether);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        tokenSale.buyTokens{value: 100 wei}();
        vm.stopPrank();
        vm.startPrank(address(this));
        tokenSale.changePreSaleStatus(false);
        tokenSale.changePublicSaleStatus(true);
        vm.stopPrank();
        vm.startPrank(address(0x123));
        token.approve(address(tokenSale), 300 ether);
        uint256 balanceBefore = address(0x123).balance;
        tokenSale.refund(0 wei);
        assertEq(address(0x123).balance, balanceBefore + 0 wei);
        vm.stopPrank();
    }

    function test_WithdrawBalance() public {
        vm.startPrank(address(this));
        vm.deal(address(tokenSale), 100 ether);
        uint256 balanceBefore = address(this).balance;
        tokenSale.withdrawBalance(address(tokenSale).balance);
        assertEq(address(tokenSale).balance, 0);
        assertEq(address(this).balance, balanceBefore + 100 ether);
        vm.stopPrank();
    }

    function test_WithdrawTokenBalance() public {
        vm.startPrank(address(this));
        uint256 balanceBefore = token.balanceOf(address(this));
        tokenSale.withdrawToken(token.balanceOf(address(tokenSale)));
        assertEq(token.balanceOf(address(tokenSale)), 0);
        assertGt(token.balanceOf(address(this)), balanceBefore);
        vm.stopPrank();
    }

    receive() external payable {}
}
