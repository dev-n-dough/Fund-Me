//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol"; // a type of script(helps in deployment of contract)
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol"; // mock contract(code from patrick collins repo) -> to deploy on anvil chain

contract HelperConfig is Script
{

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; // magic numbers

    struct NetworkConfig
    {
        address priceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() 
    {
        if(block.chainid == 11155111)
        {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else 
        {
            activeNetworkConfig = getOrCreateAnvilEthConfig();   
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory)
    {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }
    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) // cant remain pure as we are using vm
    {
        if(activeNetworkConfig.priceFeed!=address(0)) // if already a chain is selected
        {
            return activeNetworkConfig;
        }
        // we have to deploy a mock contract
        vm.startBroadcast();
        //deploying a contract = sending a real tx = wrap inside vm.broadcast
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed : address(mockPriceFeed)});
        return anvilConfig;
    }
}