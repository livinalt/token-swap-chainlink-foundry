// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/foundry-chainlink-toolkit/lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";



contract TokenSwapper {
    // addresses for tokens and price feed aggregators
    address public ethToken = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // using WETH
    address public linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address public daiToken = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;
    address public ethUsdAggregator = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address public linkUsdAggregator = 0xc59E3633BAAC79493d908e63626716e204A45EdF;
    address public daiUsdAggregator = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19;
    
    int pairResult;
    mapping(address => uint256) public ethDeposit;
    mapping(address => uint256) public linkDeposit;
    mapping(address => uint256) public daiDeposit;

    AggregatorV3Interface internal dataFeed;

    AggregatorV3Interface internal ethDataFeed;
    AggregatorV3Interface internal linkDataFeed;
    AggregatorV3Interface internal daiDataFeed;

    event TokensSwapped(address indexed from, address indexed to, address indexed token, uint256 amount);

    constructor() {
        ethDataFeed = AggregatorV3Interface(ethUsdAggregator);
        linkDataFeed = AggregatorV3Interface(linkUsdAggregator);
        daiDataFeed = AggregatorV3Interface(daiUsdAggregator);
    }

    function getLatestPrices() internal view returns (int, int, int) {
        (
            /* uint80 roundID */,
            int ethPrice,
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = ethDataFeed.latestRoundData();

        (
            /* uint80 roundID */,
            int linkPrice,
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = linkDataFeed.latestRoundData();

        (
            /* uint80 roundID */,
            int daiPrice,
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = daiDataFeed.latestRoundData();

        return (ethPrice, linkPrice, daiPrice);
    }

    function swapETHtoLINK(uint256 amount) external payable {
        // Get the latest prices from Chainlink price feeds
        (int ethPrice, int linkPrice, ) = getLatestPrices();
        
        uint256 linkAmount = (amount * uint256(ethPrice)) / uint256(linkPrice);        
        require(msg.value >= amount, "Insufficient ETH sent");
        
        require(IERC20(linkToken).transfer(msg.sender, linkAmount), "Failed to transfer LINK tokens");
        emit TokensSwapped(address(this), msg.sender, linkToken, linkAmount);
    }


    function swapLINKtoETH(uint256 amount) external {
        // Getting prices from Chainlink price feeds
        (int ethPrice, int linkPrice, ) = getLatestPrices();        
        uint256 ethAmount = (amount * uint256(linkPrice)) / uint256(ethPrice);

        require(IERC20(linkToken).balanceOf(msg.sender) >= amount, "Insufficient LINK balance");
        require(IERC20(linkToken).transferFrom(msg.sender, address(this), amount), "Failed to transfer LINK tokens");
        
        (bool success, ) = msg.sender.call{ value: ethAmount }("");
        require(success, "ETH transfer failed");
    }

    function swapETHtoDAI(uint256 amount) external payable {
        // Getting prices from Chainlink price feeds
        (int ethPrice,, int daiPrice) = getLatestPrices();
        uint256 daiAmount = (amount * uint256(ethPrice)) / uint256(daiPrice);
        
        require(msg.value >= amount, "Insufficient ETH sent");
        require(IERC20(daiToken).transfer(msg.sender, daiAmount), "Failed to transfer DAI tokens");
    }

    function swapDAItoETH(uint256 amount) external {

        (int ethPrice,,int daiPrice) = getLatestPrices();        
        uint256 ethAmount = (amount * uint256(daiPrice)) / uint256(ethPrice);

        require(IERC20(daiToken).balanceOf(msg.sender) >= amount, "Insufficient DAI balance");
        require(IERC20(daiToken).transferFrom(msg.sender, address(this), amount), "Failed to transfer DAI tokens");
        
        (bool success, ) = msg.sender.call{ value: ethAmount }("");
        require(success, "ETH transfer failed");    
    }

    function addLiquidity(uint256 ethAmount, uint256 linkAmount, uint256 daiAmount) external payable {
                
        ethDeposit[msg.sender] += ethAmount;
        linkDeposit[msg.sender] += linkAmount;
        daiDeposit[msg.sender] += daiAmount;
    }


    fallback() external payable {}

    receive() external payable {}
    
}
