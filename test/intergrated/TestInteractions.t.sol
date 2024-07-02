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
}
//     // function testUserCanFundAndOwnerCanWithdraw() public
//     // {
        
//     //     FundFundMe fundFundMe = new FundFundMe();
//     //     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

//     //     uint256 preUserBalance = USER.balance;
//     //     uint256 preOwnerbalance = fundMe.getOwner().balance;
//     //     console.log("preUserBalance %s",preUserBalance);
//     //     console.log("preOwnerbalance %s",preOwnerbalance);

//     //     vm.prank(USER);
//     //     //vm.deal(USER,INITIAL_AMOUNT);
//     //     fundMe.fund{value : fundFundMe.FUND_VALUE()}();

//     //     // vm.prank(fundMe.getOwner());
//     //     // //vm.prank(msg.sender);
//     //     // //vm.prank(address(fundMe));
//     //     // //vm.prank(address(deployFundMe));
//     //     // withdrawFundMe.withdrawFundMe(address(fundMe));

//     //     uint256 postUserBalance = USER.balance;
//     //     uint256 postOwnerbalance = fundMe.getOwner().balance;
//     //     console.log("postUserBalance %s",postUserBalance);
//     //     console.log("postOwnerbalance %s",postOwnerbalance);

//     //     // assert(address(fundMe).balance == 0);
//     //     // assert(postOwnerbalance - preOwnerbalance == preUserBalance - postUserBalance);
//     // }

//     // function testFundAndWithdrawal() public
//     // {
//     //     FundFundMe fundFundMe = new FundFundMe();
//     //     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

//     //     fundFundMe.fundFundMe(address(fundMe));
//     //     withdrawFundMe.withdrawFundMe(address(fundMe));

//     //     assert(address(fundMe).balance == 0);
//     // }
//     function testInteraction() public
//     {
//         FundFundMe fundFundMe = new FundFundMe();
//         //console.log(USER.balance);
//         vm.prank(USER);
//         //console.log(address(fundMe).balance);
//         fundFundMe.fundFundMe{value : fundFundMe.FUND_VALUE()}(address(fundMe));
//         //console.log(address(fundMe).balance);

//         WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
//         vm.prank(fundMe.getOwner());
//         // console.log(fundMe.getOwner().balance);
//         // console.log(address(fundMe).balance);
//         // console.log(address(withdrawFundMe).balance);
//         //vm.prank(address(withdrawFundMe));
//         withdrawFundMe.withdrawFundMe(address(fundMe));
//         // console.log(fundMe.getOwner().balance);
//         // console.log(address(fundMe).balance);
//         // console.log(address(withdrawFundMe).balance);
//     }
// }

///////////////////////////////////
// pasting from patrick's github //
///////////////////////////////////

// pragma solidity 0.8.19;

// import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
// import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
// import {FundMe} from "../../src/FundMe.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {Test, console} from "forge-std/Test.sol";
// import {StdCheats} from "forge-std/StdCheats.sol";
// import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

// contract InteractionsTest is ZkSyncChainChecker, StdCheats, Test {
//     FundMe public fundMe;
//     HelperConfig public helperConfig;

//     uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
//     uint256 public constant STARTING_USER_BALANCE = 10 ether;
//     uint256 public constant GAS_PRICE = 1;

//     address public constant USER = address(1);

//     // uint256 public constant SEND_VALUE = 1e18;
//     // uint256 public constant SEND_VALUE = 1_000_000_000_000_000_000;
//     // uint256 public constant SEND_VALUE = 1000000000000000000;

//     function setUp() external skipZkSync {
//         if (!isZkSyncChain()) {
//             DeployFundMe deployer = new DeployFundMe();
//             (fundMe, helperConfig) = deployer.deployFundMe();
//         } else {
//             helperConfig = new HelperConfig();
//             fundMe = new FundMe(helperConfig.getConfigByChainId(block.chainid).priceFeed);
//         }
//         vm.deal(USER, STARTING_USER_BALANCE);
//     }

//     function testUserCanFundAndOwnerWithdraw() public skipZkSync {
//         uint256 preUserBalance = address(USER).balance;
//         uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

//         // Using vm.prank to simulate funding from the USER address
//         vm.prank(USER);
//         fundMe.fund{value: SEND_VALUE}();

//         WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
//         withdrawFundMe.withdrawFundMe(address(fundMe));

//         uint256 afterUserBalance = address(USER).balance;
//         uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

//         assert(address(fundMe).balance == 0);
//         assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
//         assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
//     }
// }