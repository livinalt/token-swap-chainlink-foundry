// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TokenSwapper} from "../src/TokenSwapper.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract TokenSwapperTest is Test {
    TokenSwapper public tokenSwapper;
    address public testEthToken = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B;
    address public testLinkToken = 0x5D8B4C2554aeB7e86F387B4d6c00Ac33499Ed01f;
    address public testDaiToken = 0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa;
    
    function setUp() public {
        tokenSwapper = new TokenSwapper();
        
    }

    function testSwapETHtoLINK() public {
        uint256 ethAmount = 1e18; // 1 ETH
        tokenSwapper.swapETHtoLINK{value: ethAmount}(ethAmount);
        
        require(address(tokenSwapper).balance == ethAmount, "Incorrect ETH balance");
        
        uint256 expectedLinkAmount = ethAmount * 2;
        
        require(IERC20(testLinkToken).balanceOf(address(this)) == expectedLinkAmount, "Incorrect LINK balance");
    }

    function testSwapLINKtoETH() public {
        uint256 linkAmount = 1000 * 10**18;
        IERC20(testLinkToken).transfer(address(tokenSwapper), linkAmount);

        require(IERC20(testLinkToken).balanceOf(address(tokenSwapper)) == linkAmount, "Incorrect LINK balance in contract");

        tokenSwapper.swapLINKtoETH(linkAmount);
        uint256 expectedEthAmount = linkAmount / 2;
        
        require(address(this).balance == expectedEthAmount, "Incorrect ETH balance after swap");
    }

    function testSwapETHtoDAI() public {
        uint256 ethAmount = 1e18;
        tokenSwapper.swapETHtoDAI{value: ethAmount}(ethAmount);
        
        require(address(tokenSwapper).balance == ethAmount, "Incorrect ETH balance");

        uint256 expectedDaiAmount = ethAmount * 100;

        require(IERC20(testDaiToken).balanceOf(address(this)) == expectedDaiAmount, "Incorrect DAI balance");
    }

    function testSwapDAItoETH() public {
        uint256 daiAmount = 1000 * 10**18;
        IERC20(testDaiToken).transfer(address(tokenSwapper), daiAmount);
        
        require(IERC20(testDaiToken).balanceOf(address(tokenSwapper)) == daiAmount, "Incorrect DAI balance in contract");
        
        tokenSwapper.swapDAItoETH(daiAmount);
        uint256 expectedEthAmount = daiAmount / 3000;
        
        require(address(this).balance == expectedEthAmount, "Incorrect ETH balance after swap");
    }

    function testAddLiquidity() public {
        vm.startPrank(address(0x61E5E1ea8fF9Dc840e0A549c752FA7BDe9224e99));
        uint256 ethAmount = 10e18;
        IERC20(tokenSwapper.linkToken()).transfer(address(this), ethAmount);
        assertEq(IERC20(tokenSwapper.linkToken()).balanceOf(address(this)), ethAmount);
        vm.stopPrank();

        vm.startPrank(address(0xd0aD7222c212c1869334a680e928d9baE85Dd1d0));
        uint256 linkAmount = 10e18;
        uint256 daiAmount = 10e18;

        IERC20(testEthToken).approve(address(tokenSwapper), ethAmount);
        IERC20(testDaiToken).approve(address(tokenSwapper), daiAmount);
        IERC20(testLinkToken).approve(address(tokenSwapper), linkAmount);

        tokenSwapper.addLiquidity{ value: ethAmount }(ethAmount, linkAmount, daiAmount);

        uint256 ethBalance = tokenSwapper.ethDeposit(testEthToken);
        uint256 linkBalance = tokenSwapper.linkDeposit(testLinkToken);
        uint256 daiBalance = tokenSwapper.daiDeposit(testDaiToken);

        assertEq(ethBalance, ethAmount);
        assertEq(linkBalance, linkAmount);
        assertEq(daiBalance, daiAmount);
    }
}
