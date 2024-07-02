//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol"; // we always import contracts and use their functions, cant directly import functions
                                                     // ./ means importing from the same folder
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // i have removed /shared from this url as it is not in chainlink-brownie-contracts

error FundMe__NotOwner();

contract FundMe
{

    using PriceConverter for uint256;

    uint256 public constant MIN_USD = 5 * 1e18; // should also have 18 DP

    // make variables private and write getter functions

    address[] private s_funders; // storage variables to start with s_(help in pointing out gas heavy tasks)
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

    address private immutable i_owner ; //immutable(variables only set once) to start with i_
    AggregatorV3Interface private s_priceFeed; 

    constructor (address priceFeed)
    {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable //payable keyword imp
    {
        require(msg.value.getConversionRate(s_priceFeed) >= MIN_USD,"didn't send enough money"); // these funds are given to this contract , hence can be accessed using address(this).balance

        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;// this is just a way to keep track of the funds , they arent actually stored here
    }

    function cheaperWithdraw() public onlyOwner
    {
        uint256 fundersLength = s_funders.length;
        for (uint i=0;i< fundersLength;i++)
        {
            s_addressToAmountFunded[s_funders[i]]=0; //set all funds to 0
        }
        s_funders= new address[](0); // reset funders array
        (bool callSuccess, )= payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"call failed");
    }

    function withdraw() public onlyOwner
    {
        for (uint i=0;i< s_funders.length;i++)
        {
            s_addressToAmountFunded[s_funders[i]]=0; //set all funds to 0
        }
        s_funders= new address[](0); // reset funders array
        (bool callSuccess, )= payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess,"call failed");
    }

    function getVersion() public view returns(uint256)
    {
        return s_priceFeed.version();
    }

    modifier onlyOwner()
    {
        //require(msg.sender == i_owner, "Must be owner! ");
        if(msg.sender != i_owner)
        {
            revert FundMe__NotOwner(); // named errors are better
        }
         _; // IMP !!!
    }

    receive() external payable 
    {
        fund();
    }

    fallback() external payable 
    {
        fund();
    }

    //write some view/pure getter functions (for private variables)
    // makes code neat and readable

    function getAddressToAmountFunded(address fundingAddress) external view returns(uint256)
    {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address)
    {
        return s_funders[index];
    }

    function getOwner() external view returns(address)
    {
        return i_owner;
    }
}