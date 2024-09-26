//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol"; // console.log for debugging
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; // importing script so and using it to initialise test with the same initial conditions
import {FundFundMe , WithdrawFundMe} from "../../script/Interactions.s.sol";

contract TestInteractions is Test
{
    FundMe fundMe; // in bigger scope - so that it is used by other functions also
    DeployFundMe deployFundMe;

    uint256 constant SEND_VALUE = 0.05 ether;
    uint256 constant INITIAL_AMOUNT = 15 ether;
 
    address USER = makeAddr("user");
    
    function setUp() external
    {
        deployFundMe = new DeployFundMe(); // create an instance(imp step)
        fundMe = deployFundMe.run();
        vm.deal(USER,INITIAL_AMOUNT);
    }

    function testUserCanFundInteractions() public
    {
        
        FundFundMe fundFundMe = new FundFundMe{value: SEND_VALUE}();
        vm.prank(USER); // USER is now asking FundFundMe to call the fundFundMe function
        // ans inside the fundFundMe function(in Interactions script) I am again pranking USER,
        // now USER will call fund function of FundMe

        uint256 startingSenderBalance = address(fundFundMe).balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        fundFundMe.fundFundMe(address(fundMe));
        // fundMe.fund{value : 0.05 ether}();

        uint256 endingSenderBalance = address(fundFundMe).balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assert(startingSenderBalance-endingSenderBalance == endingFundMeBalance - startingFundMeBalance);
        

        address funder = fundMe.getFunder(0); 
        assertEq(funder,address(fundFundMe));

        uint256 amountFunded = fundMe.getAddressToAmountFunded(address(fundFundMe));
        assertEq(amountFunded,SEND_VALUE);
    }

    function testOwnerCanWithdrawInteractions() public
    {
        address ownerOfFundMe = fundMe.getOwner();

        FundFundMe fundFundMe = new FundFundMe{value:SEND_VALUE}();
        fundFundMe.fundFundMe(address(fundMe));

        uint256 startingOwnerBalance = ownerOfFundMe.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.WithdrawFundMeTEST(address(fundMe));

        uint256 endingOwnerBalance = ownerOfFundMe.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assert(endingOwnerBalance-startingOwnerBalance == startingFundMeBalance - endingFundMeBalance);


        assert(address(fundMe).balance == 0);
    }

    function testUserCanFundAndOwnerCanWithdraw() public
    {
        FundFundMe fundFundMe = new FundFundMe{value: SEND_VALUE}();
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        vm.prank(USER);
        fundFundMe.fundFundMe(address(fundMe));
        vm.prank(fundMe.getOwner());



        
        // withdrawFundMe.withdrawFundMe(address(fundMe)); // --> Here, vm.prank() only affects the call to withdrawFundMe.withdrawFundMe(), not the subsequent withdraw() call inside that function.

        // since in testing we have to use pranking and it has this issue , hence it makes it difficult to test this interaction script

        // but i have tested it on sepolia , and it works there
        // (note that here our address is owner of fund me)





        FundMe(payable(address(fundMe))).withdraw();
    }

}