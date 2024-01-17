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

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
