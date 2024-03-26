// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { TokenSwapper } from "../src/TokenSwapper.sol";
import { IERC20 } from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract TokenSwapperTest is Test {
    TokenSwapper public tokenSwapper;

    // uint256 ethAmount;
    uint256 price;

     //sepolia address for ETH, LINK and DAI
    address public ethToken = 0xd38E5c25935291fFD51C9d66C3B7384494bb099A;
    address public linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address public daiToken = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;

    // Chainlink aggregator addresses for token price feeds
    address public ethUsdAggregator = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // Address of eth to usd price feed aggregator
    address public linkUsdAggregator = 0xc59E3633BAAC79493d908e63626716e204A45EdF; // Address of link to usd price feed aggregator
    address public daiUsdAggregator = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19;  // Address of dai to usd price feed aggregator

    // Sets up TokenSwapper contract before each test
    function setUp() public {
        tokenSwapper = new TokenSwapper(
           
        );
    }
function testChainLinkPriceFeed() public {
    int result = tokenSwapper.getChainlinkDataFeedLatestAnswer(linkUsdAggregator);
    // console2.log(result);
    assertGt(result, 1);
}

function testAddLiquidity() public {
    uint256 linkAmount = 10e18;
    IERC20(tokenSwapper.linkToken()).transfer(address(this), linkAmount);
    assertEq(IERC20(tokenSwapper.linkToken()).balanceOf(address(this)), linkAmount);

    uint256 ethAmount = 10e18;
    uint256 daiAmount = 10e18;

    tokenSwapper.addLiquidity{ value: ethAmount }(ethAmount, linkAmount, daiAmount);

    uint256 ethBalance = tokenSwapper.ethDeposit();
    uint256 linkBalance = tokenSwapper.linkDeposit();
    uint256 daiBalance = tokenSwapper.daiDeposit();

    assertEq(ethBalance, ethAmount);
    assertEq(linkBalance, linkAmount);
    assertEq(daiBalance, daiAmount);
}

function testSwapETHtoLINK() public {
    uint256 ethAmount = 1 ether; // Set the amount of ETH to swap (1 ETH)

    // Get the expected amount of LINK to receive based on the current exchange rate
    // int256 price = tokenSwapper.(tokenSwapper.ethUsdAggregator());
    uint256 expectedLINKAmount = (ethAmount * price) / 1e18; // Adjust for Chainlink decimals (18)

    uint256 initialLINKBalance = IERC20(tokenSwapper.linkToken()).balanceOf(address(this));

    // Perform swap ETH to LINK transaction
    tokenSwapper.swapETHtoLINK{ value: ethAmount }(ethAmount);

    uint256 finalLINKBalance = IERC20(tokenSwapper.linkToken()).balanceOf(address(this));

    // Assert that the LINK balance has increased by the correct amount
    assertEq(finalLINKBalance - initialLINKBalance, expectedLINKAmount);
}

function testSwapLINKtoETH() public {
    uint256 linkAmount = 100e18; // Set the amount of LINK to swap (100 LINK)
    uint256 initialETHBalance = address(this).balance;

    // Perform swap LINK to ETH transaction
    tokenSwapper.swapLINKtoETH(linkAmount);

    uint256 finalETHBalance = address(this).balance;

    // Assert that the ETH balance has increased by the correct amount
    assertGt(finalETHBalance, initialETHBalance);
}

function testSwapDAItoETH() public {
    uint256 daiAmount = 100e18; // Set the amount of DAI to swap (100 DAI)
    uint256 initialETHBalance = address(this).balance;

    // Perform swap DAI to ETH transaction
    tokenSwapper.swapDAItoETH(daiAmount);

    uint256 finalETHBalance = address(this).balance;

    // Assert that the ETH balance has increased by the correct amount
    assertGt(finalETHBalance, initialETHBalance);
}

function testSwapETHtoDAI() public {
    uint256 ethAmount = 1 ether; // Set the amount of ETH to swap (1 ETH)
    uint256 initialDaiBalance = IERC20(tokenSwapper.daiToken()).balanceOf(address(this));

    // Perform swap ETH to DAI transaction
    tokenSwapper.swapETHtoDAI{ value: ethAmount }(ethAmount);

    uint256 finalDaiBalance = IERC20(tokenSwapper.daiToken()).balanceOf(address(this));

    // Assert that the DAI balance has increased by the correct amount
    assertGt(finalDaiBalance, initialDaiBalance);
}

}
