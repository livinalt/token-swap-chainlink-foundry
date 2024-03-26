// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import { Test, console } from "forge-std/Test.sol";
import { TokenSwapper } from "../src/TokenSwapper.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract TokenSwapperTest is Test {
    TokenSwapper public tokenSwapper;

     //sepolia address for ETH, LINK and DAI
            address public ethToken = 0xd38E5c25935291fFD51C9d66C3B7384494bb099A;
            address public linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
            // address public daiToken = 0x3e622317f8c93f7328350cf0b56d9ed4c620c5d6;

            // Chainlink aggregator addresses for token price feeds
            address public eth_usd_address = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // Address of eth to usd price feed aggregator
            address public link_usd_feed_address = 0xc59E3633BAAC79493d908e63626716e204A45EdF; // Address of link to usd price feed aggregator
            address public dai_usd_feed_address = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19;  // Address of dai to usd price feed aggregator

    // Set up the TokenSwapper contract before each test
    function setUp() public {
        tokenSwapper = new TokenSwapper(
            ethToken, linkToken, eth_usd_address, link_usd_feed_address, dai_usd_feed_address
        );
        
    }

    // Test swapping ETH to LINK
    // function testSwapETHtoLINK() public {
    //     uint256 ethAmount = 1 ether; // Set the amount of ETH to swap (1 ETH)
    //     uint256 initialLINKBalance = IERC20(tokenSwapper.linkToken()).balanceOf(address(this));

    //     // Perform swap ETH to LINK transaction
    //     tokenSwapper.swapETHtoLINK{ value: ethAmount }(ethAmount);

    //     uint256 finalLINKBalance = IERC20(tokenSwapper.linkToken()).balanceOf(address(this));

    //     // Assert that the LINK balance has increased by the correct amount
    //     assertEq(finalLINKBalance - initialLINKBalance, expectedLINKAmount);
    // }

    // // Test swapping LINK to ETH
    // function testSwapLINKtoETH() public {
    //     uint256 linkAmount = 100e18; // Set the amount of LINK to swap (100 LINK)
    //     uint256 initialETHBalance = address(this).balance;

    //     // Perform swap LINK to ETH transaction
    //     tokenSwapper.swapLINKtoETH(linkAmount);

    //     uint256 finalETHBalance = address(this).balance;

    //     // Assert that the ETH balance has increased by the correct amount
    //     assertEq(finalETHBalance - initialETHBalance, expectedETHAmount);
    // }

    // Test adding liquidity
    function testAddLiquidity() public {
        uint256 ethAmount = 1 ether; 
        uint256 linkAmount = 100e18; 
        uint256 daiAmount = 500e18; 

        uint256 initialEthBalance = IERC20(tokenSwapper.ethToken()).balanceOf(address(this));
        uint256 initialLinkBalance = IERC20(tokenSwapper.linkToken()).balanceOf(address(this));
        uint256 initialDaiBalance = IERC20(tokenSwapper.daiToken()).balanceOf(address(this));

        //add liquidity transaction
        tokenSwapper.addLiquidity{ value: ethAmount }(ethAmount, linkAmount, daiAmount);

        uint256 finalEthBalance = IERC20(tokenSwapper.ethToken()).balanceOf(address(this));
        uint256 finalLinkBalance = IERC20(tokenSwapper.linkToken()).balanceOf(address(this));
        uint256 finalDaiBalance = IERC20(tokenSwapper.daiToken()).balanceOf(address(this));

        // Assert that the ETH, LINK, and DAI balances have increased by the correct amounts
        assertEq(finalEthBalance - initialEthBalance, ethAmount);
        assertEq(finalLinkBalance - initialLinkBalance, linkAmount);
        assertEq(finalDaiBalance - initialDaiBalance, daiAmount);
    }

    // Test getting price from a price feed
    function testGetPrice() public view {
        uint256 ethPrice = tokenSwapper.getPrice(tokenSwapper.eth_usd_address());
        uint256 linkPrice = tokenSwapper.getPrice(tokenSwapper.link_usd_feed_address());
        uint256 daiPrice = tokenSwapper.getPrice(tokenSwapper.dai_usd_feed_address());

        // Assert that the price returned is not zero
        assertTrue(ethPrice > 0);
        assertTrue(linkPrice > 0);
        assertTrue(daiPrice > 0);
    }
}
