// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/foundry-chainlink-toolkit/lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";



contract TokenSwapper {

    //sepolia address for ETH, LINK and DAI
    address public ethToken = 0xd38E5c25935291fFD51C9d66C3B7384494bb099A;
    address public linkToken = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    // address public daiToken = 0x3e622317f8c93f7328350cf0b56d9ed4c620c5d6;
    address public daiToken = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19;

    // Chainlink aggregator addresses for token price feeds
    address public eth_usd_address = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // Address of eth to usd price feed aggregator
    address public link_usd_feed_address = 0xc59E3633BAAC79493d908e63626716e204A45EdF; // Address of link to usd price feed aggregator
    address public dai_usd_feed_address = 0x14866185B1962B63C3Ea9E03Bc1da838bab34C19;  // Address of dai to usd price feed aggregator

    // event LiquidityAdded(address.target, ethAmount, linkAmount, daiAmount);


    constructor(
        address _ethToken, 
        address _linkToken, 
        address _daiToken,
        address _eth_usd_address,
        address _link_usd_feed_address
        // address _dai_usd_feed_address,
    ) {
        ethToken = _ethToken;
        linkToken = _linkToken;
        daiToken = _daiToken;
        eth_usd_address = _eth_usd_address;
        link_usd_feed_address = _link_usd_feed_address;
        // dai_usd_feed_address = _dai_usd_feed_address;
    }

    function swapETHtoLINK(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        
        // Get the ETH to LINK conversion rate from Chainlink
        AggregatorV3Interface ethToLinkPriceFeed = AggregatorV3Interface(eth_usd_address);
        (, int256 price, , , ) = ethToLinkPriceFeed.latestRoundData();
        uint256 linkAmount = (amount * uint256(price)) / 1e18; // Adjust for Chainlink decimals (18)

        // Transfer ETH from sender to contract
        require(msg.value >= amount, "Insufficient ETH provided");
        
        // Transfer LINK from contract to sender
        require(IERC20(linkToken).transfer(msg.sender, linkAmount), "Failed to transfer LINK");
    }

    function swapLINKtoETH(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        // Get the LINK to ETH conversion rate from Chainlink
        AggregatorV3Interface linkToEthPriceFeed = AggregatorV3Interface(link_usd_feed_address);
        (, int256 price, , , ) = linkToEthPriceFeed.latestRoundData();
        uint256 ethAmount = (amount * uint256(price)) / 1e18; // Adjust for Chainlink decimals (18)

        // Transfer LINK from sender to contract
        require(IERC20(linkToken).transferFrom(msg.sender, address(this), amount), "Failed to transfer LINK");
        
        // Transfer ETH from contract to sender
        (bool success, ) = msg.sender.call{value: ethAmount}("");
        require(success, "ETH transfer failed");
    }

    function swapDAItoETH(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        // Get the DAI to ETH conversion rate from Chainlink
        AggregatorV3Interface daiToEthPriceFeed = AggregatorV3Interface(dai_usd_feed_address);
        (, int256 price, , , ) = daiToEthPriceFeed.latestRoundData();
        uint256 ethAmount = (amount * uint256(price)) / 1e18; // Adjust for Chainlink decimals (18)

        // Transfer DAI from sender to contract
        require(IERC20(daiToken).transferFrom(msg.sender, address(this), amount), "Failed to transfer DAI");
        
        // Transfer ETH from contract to sender
        (bool success, ) = msg.sender.call{value: ethAmount}("");
        require(success, "ETH transfer failed");
    }

    function swapETHtoDAI(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        
        // Get the ETH to DAI conversion rate from Chainlink
        AggregatorV3Interface ethToDaiPriceFeed = AggregatorV3Interface(dai_usd_feed_address);
        (, int256 price, , , ) = ethToDaiPriceFeed.latestRoundData();
        uint256 daiAmount = (amount * uint256(price)) / 1e18; // Adjust for Chainlink decimals (18)

        // Transfer ETH from sender to contract
        require(msg.value >= amount, "Insufficient ETH provided");
        
        // Transfer DAI from contract to sender
        require(IERC20(daiToken).transfer(msg.sender, daiAmount), "Failed to transfer DAI");
    }

    // function swapLINKtoDAI(uint256 amount) external {
    //     require(amount > 0, "Amount must be greater than 0");
        
    //     // Get the LINK to DAI conversion rate from Chainlink
    //     AggregatorV3Interface linkToDaiPriceFeed = AggregatorV3Interface(daiToLinkPriceFeedAddress);
    //     (, int256 price, , , ) = linkToDaiPriceFeed.latestRoundData();
    //     uint256 daiAmount = (amount * uint256(price)) / 1e18; // Adjust for Chainlink decimals (18)

    //     // Transfer LINK from sender to contract
    //     require(IERC20(linkToken).transferFrom(msg.sender, address(this), amount), "Failed to transfer LINK");
        
    //     // Transfer DAI from contract to sender
    //     require(IERC20(daiToken).transfer(msg.sender, daiAmount), "Failed to transfer DAI");
    // }

    // function swapDAItoLINK(uint256 amount) external {
    //     require(amount > 0, "Amount must be greater than 0");
        
    //     // Get the DAI to LINK conversion rate from Chainlink
    //     AggregatorV3Interface daiToLinkPriceFeed = AggregatorV3Interface(daiToLinkPriceFeedAddress);
    //     (, int256 price, , , ) = daiToLinkPriceFeed.latestRoundData();
    //     uint256 linkAmount = (amount * uint256(price)) / 1e18; // Adjust for Chainlink decimals (18)

    //     // Transfer DAI from sender to contract
    //     require(IERC20(daiToken).transferFrom(msg.sender, address(this), amount), "Failed to transfer DAI");
        
    //     // Transfer LINK from contract to sender
    //     require(IERC20(linkToken).transfer(msg.sender, linkAmount), "Failed to transfer LINK");
    // }

     function addLiquidity(uint256 ethAmount, uint256 linkAmount, uint256 daiAmount) external payable {
        // Ensure the user provides sufficient ETH
        require(msg.value >= ethAmount, "Insufficient ETH provided");

        // Transfer ETH, LINK, and DAI from the sender to the contract
        require(IERC20(ethToken).transferFrom(msg.sender, address(this), ethAmount), "Failed to transfer ETH");
        require(IERC20(linkToken).transferFrom(msg.sender, address(this), linkAmount), "Failed to transfer LINK");
        require(IERC20(daiToken).transferFrom(msg.sender, address(this), daiAmount), "Failed to transfer DAI");

        // Emit an event indicating the liquidity addition
        // emit LiquidityAdded(msg.sender, ethAmount, linkAmount, daiAmount);
    }

    function getPrice(address priceFeedAddress) external view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }
}
