// //SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script
{
    uint256 public constant FUND_VALUE = 0.05 ether;
    uint256 public receivedAmount;

    constructor() payable {
        receivedAmount = msg.value; // should be >= FUND_VALUE
    }

    function fundFundMe(address _mostRecentDeployment) public /*payable*/ // how tf is this not payable and still working // lol because it is sending eth and not receiving it. the constructor is payable
    {
        FundMe(payable(_mostRecentDeployment)).fund{value:FUND_VALUE}();
        console.log("Funded FundMe with %s",FUND_VALUE);
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
        FundMe(payable(_mostRecentDeployment)).withdraw();
        console.log("Withdrew funds from FundMe ");
    }

    function run() external
    {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe",block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }

    // this function is for testing purposes only
    function WithdrawFundMeTEST(address _mostRecentDeployment) public
    {
        FundMe latestFundMe = FundMe(payable(_mostRecentDeployment));
        address ownerOfFundMe = latestFundMe.getOwner();
        vm.prank(ownerOfFundMe);
        latestFundMe.withdraw();
        console.log("Withdrew funds from FundMe(TEST ONLY FUNCTION) ");
    }
}
