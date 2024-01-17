// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/**
 * @title SupraOracleToken
 * @author Anjanay Raina
 * @dev Very simple ERC20 Token
 */

contract SupraOracleToken is ERC20, Ownable {
    constructor(address initialOwner) ERC20("SupraOracle Token", "SOT") Ownable(initialOwner) {}
/**
    * @dev Mints a specific amount of tokens to a given account.
    * @param to The account for which the tokens will be minted .
    * @param amount The amount of tokens to mint.
    */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

/**
    * @dev Burns a specific amount of tokens from a given account.
    * @param account The account whose tokens will be burnt.
    * @param amount The amount of tokens to burn.
    */
   function burnFrom(address account, uint256 amount) public onlyOwner {
       _burn(account, amount);
   }
}
