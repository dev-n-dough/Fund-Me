//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // i have removed /shared from this url as it is not in chainlink-brownie-contracts


library PriceConverter
{
    function getPrice(AggregatorV3Interface priceFeed) public view returns(uint256)
    {
        // to deploy another contract within this contract , we need 2 things, address and abi of that contract, both avl on chainlink documentation
        // address : 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // abi : import the interface of that contract(which we have done on line 5)

        (,int256 price,,,)=priceFeed.latestRoundData();
        //returns price of ETH in USD
        // number of decimal places here will be 8
        // in msg.sender(), no of DP will be 18 (math is weird in solidity)
        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount , AggregatorV3Interface priceFeed) public view returns(uint256)
    {
        uint256 ethPrice = getPrice(priceFeed); // has 18 DP
        uint ethAmountInUsd = (ethPrice * ethAmount)/1e18; // as both price and amount have 18 DP , the answer would end up having 36 DP , hence divide by 18 DP
        return ethAmountInUsd ; // has 18 DP
    }
}

// making this a contract(instead of a library) is also fine 