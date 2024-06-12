//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script
{
    uint256 public constant FUND_VALUE = 0.05 ether;

    function fundFundMe(address _mostRecentDeployment) public payable
    {
        //vm.startBroadcast();
        FundMe(payable(_mostRecentDeployment)).fund{value:FUND_VALUE}();
        //vm.stopBroadcast();
        //console.log("Funded FundMe with %s",FUND_VALUE);
    }

    function run() external
    {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script
{
    function withdrawFundMe(address _mostRecentDeployment) public
    {
        //vm.startBroadcast();
        FundMe fundMe = FundMe(payable(_mostRecentDeployment));

        console.log(address(fundMe).balance);

        fundMe.withdraw();

        console.log(address(fundMe).balance);

        //vm.stopBroadcast();
    }

    function run() external
    {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }
}