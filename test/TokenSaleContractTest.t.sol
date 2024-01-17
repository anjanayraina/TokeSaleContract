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

  
}