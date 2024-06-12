//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol"; // console.log for debugging
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; // importing script so and using it to initialise test with the same initial conditions


contract TestFundMe is Test
{
    FundMe fundMe; // in bigger scope - so that it is used by other functions also

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_AMOUNT = 15 ether;
    uint256 constant GAS_PRICE = 1;

    address USER = makeAddr("user");
    
    function setUp() external
    {
        //fundMe = new FundMe();
        //fundMe = DeployFundMe.run();
        DeployFundMe deployFundMe = new DeployFundMe(); // create an instance(imp step)
        fundMe = deployFundMe.run();
        vm.deal(USER,INITIAL_AMOUNT);
    }

    function testMinimumDollarIsFive() public view
    {
        assertEq(fundMe.MIN_USD(),5e18); // MIN_USD - wrong , MIN_USD() - right
    }

    function testOwnerIsMsgSender() public view
    {
        //assertEq(fundMe.i_owner(),address(this)); // we -> TestFundMe -> FundMe : hence TestFundMe(which is address(this)) is owner of FundMe
        assertEq(fundMe.getOwner(),msg.sender) ;// we are making fundMe via the script , hence we(msg.sender) are creator(and owner) of the contract
    }
    
    function testPriceFeedVersionIsAccurate() external view
    {
        uint256 version = fundMe.getVersion(); // had to define getVersion in FundMe , else create an instance of FundMe.PriceConverter priceConverter = new FundMe.PriceConverter(); and use priceConverter.getVersion() .abi
        assertEq(version,4);
    }
    function testFundFailsWithoutEnoughEth() public
    {
        vm.expectRevert();
        fundMe.fund();//sending 0 eth
    }
    function testFundUpdatesFundedDataStructure() public
    {
        vm.prank(USER); // next txn will be sent by USER
        fundMe.fund{value : SEND_VALUE}(); 
        //uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public
    {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();

        address funder = fundMe.getFunder(0); // everytime test is called it will run setUp and then the a test function
        assertEq(funder,USER);
    }

    modifier funded()
    {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded
    {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded
    {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        //Act


        /*
        uint256 gasStart =gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // tx.gasprice - right , tx.gasprice() - wrong
        console.log(gasUsed);
        */

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public funded
    {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex;i<numberOfFunders;i++)
        {
            //vm.prank
            //vm.deal
            //fund the contract
            hoax(address(i),INITIAL_AMOUNT); // prank + deal = hoax
            fundMe.fund{value : SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawWithMultipleFundersCheaper() public funded
    {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex;i<numberOfFunders;i++)
        {
            //vm.prank
            //vm.deal
            //fund the contract
            hoax(address(i),INITIAL_AMOUNT);
            fundMe.fund{value : SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}



// we -> TestFundMe -> FundMe : hence TestFundMe(which is address(this)) is owner of FundMe