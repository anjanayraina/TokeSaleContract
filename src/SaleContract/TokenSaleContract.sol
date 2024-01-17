// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MyTokenSale
 * @author Anjanay Raina
 * @dev A contract for selling tokens in presale and public sale phases.
 */
contract MyTokenSale is Ownable {
    IERC20 public token;
    bool public isPreSaleActive;
    bool public isPublicSaleActive;
    uint256 public constant PRE_SALE_CAP = 1000 ether;
    uint256 public constant PUBLIC_SALE_CAP = 5000 ether;
    uint256 public constant PRESALE_MINIMUM_CONTRIBUTION_PER_PARTICIPANT = 10 ether;
    uint256 public constant PUBLICSALE_MINIMUM_CONTRIBUTION_PER_PARTICIPANT = 20 ether;
    uint256 public constant PRESALE_MAXIMUM_CONTRIBUTION_PER_PARTICIPANT = 100 ether;
    uint256 public constant PUBLICSALE_MAXIMUM_CONTRIBUTION_PER_PARTICIPANT = 200 ether;

    error SaleNotActive();

    mapping(address => uint256) public contributions;

    /**
     * @dev Constructs a new token sale contract.
     * @param tokenAddress The address of the token contract.
     * @param initialOwner The address of the owner of the contract
     *
     */
    constructor(IERC20 tokenAddress, address initialOwner) Ownable(initialOwner) {
        token = tokenAddress;
    }

    function changePreSaleStatus(bool status) external onlyOwner {
        isPreSaleActive = status;
    }

    function changePublicSaleStatus(bool status) external onlyOwner {
        isPublicSaleActive = status;
    }

    /**
     * @dev Buys tokens in the presale or public sale.
     */
    function buyTokens() external payable {
        if (!isPreSaleActive && !isPublicSaleActive) {
            revert SaleNotActive();
        }
        uint256 tokensToBuy = _calculateTokens(msg.value);
        contributions[msg.sender] += msg.value;
    }

    /**
     * @dev Calculates the number of tokens to buy based on the contributed Ether.
     * @param ethAmount The amount of Ether contributed.
     * @return The number of tokens to buy.
     */
    function _calculateTokens(uint256 ethAmount) internal pure returns (uint256) {
        // Implement your token price calculation logic here
        // For simplicity, we'll assume that 1 ETH = 10 token
        return 10 * ethAmount;
    }

    /**
     * @dev Distributes tokens to a specified address.
     * @param beneficiary The address to distribute tokens to.
     * @param amount The number of tokens to distribute.
     */
    function distributeTokens(address beneficiary, uint256 amount) external onlyOwner {
        token.transfer(beneficiary, amount);
    }
}
