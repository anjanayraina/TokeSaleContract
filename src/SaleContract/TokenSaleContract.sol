// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
/**
 * @title MyTokenSale
 * @author Anjanay Raina
 * @dev A contract for selling tokens in presale and public sale phases.
 */

contract TokenSaleContract is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public token;
    bool public isPreSaleActive;
    bool public isPublicSaleActive;
    uint256 public constant PRE_SALE_CAP = 1000 ether;
    uint256 public constant PUBLIC_SALE_CAP = 5000 ether;
    uint256 public constant PRESALE_MINIMUM_CONTRIBUTION_PER_PARTICIPANT = 10 ether;
    uint256 public constant PUBLICSALE_MINIMUM_CONTRIBUTION_PER_PARTICIPANT = 20 ether;
    uint256 public constant PRESALE_MAXIMUM_CONTRIBUTION_PER_PARTICIPANT = 100 ether;
    uint256 public constant PUBLICSALE_MAXIMUM_CONTRIBUTION_PER_PARTICIPANT = 200 ether;
    uint256 totalContributions;

    event PresaleStatusChanged(bool status);
    event PublicSaleStatusChanged(bool status);
    event TokensPurchased(address indexed buyer, uint256 amount);
    event TokensDistributed(address indexed recipient, uint256 amount);
    event RefundProcessed(address indexed refunder, uint256 amount);

    error SaleNotActive();
    error PreSaleCapExcedded();
    error PostSaleCapExcedded();
    error PreSaleStillActive();
    error BalanceHigherThanMinimmum();

    mapping(address => uint256) public contributions;

    /**
     * @dev Sets the parameters for the token sale contract
     * @param tokenAddress The address of the token contract.
     * @param initialOwner The address of the owner of the contract
     */
    constructor(IERC20 tokenAddress, address initialOwner) Ownable(initialOwner) {
        token = tokenAddress;
    }

    // External functions

    /**
     * @dev Changes the status of the presale
     * @param status The new status of the presale
     */
    function changePreSaleStatus(bool status) external onlyOwner {
        isPreSaleActive = status;
        emit PresaleStatusChanged(status);
    }
    /**
     * @dev Changes the status of the public sale
     * @param status The new status of the public sale
     */

    function changePublicSaleStatus(bool status) external onlyOwner {
        isPublicSaleActive = status;
        emit PublicSaleStatusChanged(status);
    }

    /**
     * @dev Buys tokens in the presale or public sale.
     */
    function buyTokens() external payable nonReentrant {
        address caller = msg.sender;
        if (!isPreSaleActive && !isPublicSaleActive) {
            revert SaleNotActive();
        }
        if (
            isPreSaleActive
                && (
                    ((totalContributions + msg.value) > PRE_SALE_CAP)
                        || ((contributions[caller] + msg.value) > PRESALE_MAXIMUM_CONTRIBUTION_PER_PARTICIPANT)
                )
        ) {
            revert PreSaleCapExcedded();
        }

        if (
            isPublicSaleActive
                && (
                    ((totalContributions + msg.value) > PUBLIC_SALE_CAP)
                        || ((contributions[caller] + msg.value) > PUBLICSALE_MAXIMUM_CONTRIBUTION_PER_PARTICIPANT)
                )
        ) {
            revert PostSaleCapExcedded();
        }
        uint256 tokensToBuy = _calculateTokens(msg.value);
        contributions[caller] += msg.value;
        totalContributions += msg.value;
        token.safeTransfer(caller, tokensToBuy);
        emit TokensPurchased(caller, tokensToBuy);
    }

    /**
     * @dev Distributes tokens to a specified address.
     * @param to The address to distribute tokens to.
     * @param amount The number of tokens to distribute.
     */
    function distributeTokens(address to, uint256 amount) external onlyOwner {
        token.safeTransfer(to, amount);
        emit TokensDistributed(to, amount);
    }

    /**
     * @dev Refunds eth to the caller.
     * @param amount The amount of eth to be refunded .
     */
    function refund(uint256 amount) external nonReentrant {
        address caller = msg.sender;
        if (isPreSaleActive) {
            revert PreSaleStillActive();
        } else if (!isPublicSaleActive) {
            if (contributions[caller] < PUBLICSALE_MINIMUM_CONTRIBUTION_PER_PARTICIPANT) {
                revert BalanceHigherThanMinimmum();
            }
            uint256 tokenAmount = _calculateTokens(amount);
            token.safeTransferFrom(caller, address(this), tokenAmount);
            contributions[caller] -= amount;
            (bool success,) = payable(caller).call{value: amount}("");
            require(success);
        } else {
            if (contributions[caller] < PRESALE_MINIMUM_CONTRIBUTION_PER_PARTICIPANT) {
                revert BalanceHigherThanMinimmum();
            }
            uint256 tokenAmount = _calculateTokens(amount);
            token.safeTransferFrom(caller, address(this), tokenAmount);
            contributions[caller] -= amount;
            (bool success,) = payable(caller).call{value: amount}("");
            require(success);
        }
        emit RefundProcessed(caller, amount);
    }
    /**
     * @dev Withdraws the eth balance of the contract
     * @param amount The amount of eth to withdraw
     */

    function withdrawBalance(uint256 amount) external onlyOwner {
        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success);
    }

    /**
     * @dev Withdraws the token balance of the contract
     * @param amount The amount of tokens to withdraw
     */
    function withdrawTokens(uint256 amount) external onlyOwner {
        token.safeTransfer(msg.sender, amount);
    }

    // Internal functions
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
}
