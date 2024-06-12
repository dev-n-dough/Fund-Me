//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol"; // console.log for debugging
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; // importing script so and using it to initialise test with the same initial conditions
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract TestInteractions is Test
{
    FundMe fundMe; // in bigger scope - so that it is used by other functions also
    DeployFundMe deployFundMe;

    //uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_AMOUNT = 15 ether;
    //uint256 constant GAS_PRICE = 1;
 
    //address USER = makeAddr("user");
    address USER = address(1);
    
    function setUp() external
    {
        deployFundMe = new DeployFundMe(); // create an instance(imp step)
        fundMe = deployFundMe.run();
        vm.deal(USER,INITIAL_AMOUNT);
    }

    // function testUserCanFundAndOwnerCanWithdraw() public
    // {
        
    //     FundFundMe fundFundMe = new FundFundMe();
    //     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

    //     uint256 preUserBalance = USER.balance;
    //     uint256 preOwnerbalance = fundMe.getOwner().balance;
    //     console.log("preUserBalance %s",preUserBalance);
    //     console.log("preOwnerbalance %s",preOwnerbalance);

    //     vm.prank(USER);
    //     //vm.deal(USER,INITIAL_AMOUNT);
    //     fundMe.fund{value : fundFundMe.FUND_VALUE()}();

    //     // vm.prank(fundMe.getOwner());
    //     // //vm.prank(msg.sender);
    //     // //vm.prank(address(fundMe));
    //     // //vm.prank(address(deployFundMe));
    //     // withdrawFundMe.withdrawFundMe(address(fundMe));

    //     uint256 postUserBalance = USER.balance;
    //     uint256 postOwnerbalance = fundMe.getOwner().balance;
    //     console.log("postUserBalance %s",postUserBalance);
    //     console.log("postOwnerbalance %s",postOwnerbalance);

    //     // assert(address(fundMe).balance == 0);
    //     // assert(postOwnerbalance - preOwnerbalance == preUserBalance - postUserBalance);
    // }

    // function testFundAndWithdrawal() public
    // {
    //     FundFundMe fundFundMe = new FundFundMe();
    //     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

    //     fundFundMe.fundFundMe(address(fundMe));
    //     withdrawFundMe.withdrawFundMe(address(fundMe));

    //     assert(address(fundMe).balance == 0);
    // }
    function testInteraction() public
    {
        FundFundMe fundFundMe = new FundFundMe();
        //console.log(USER.balance);
        vm.prank(USER);
        //console.log(address(fundMe).balance);
        fundFundMe.fundFundMe{value : fundFundMe.FUND_VALUE()}(address(fundMe));
        //console.log(address(fundMe).balance);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        vm.prank(fundMe.getOwner());
        // console.log(fundMe.getOwner().balance);
        // console.log(address(fundMe).balance);
        // console.log(address(withdrawFundMe).balance);
        //vm.prank(address(withdrawFundMe));
        withdrawFundMe.withdrawFundMe(address(fundMe));
        // console.log(fundMe.getOwner().balance);
        // console.log(address(fundMe).balance);
        // console.log(address(withdrawFundMe).balance);
    }
}