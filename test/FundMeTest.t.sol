// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        //先运行
        //number = 2;
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimunDollarIsFive() public {
        assertEq(fundMe.minimum_Usd(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        //us->FunderMeTest->Fundme
        assertEq(fundMe.owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    //0x694AA1769357215DE4FAC081bf1f309aDC325306

    //test function
    //unit test
    //integration
    //forked
    //staging
}
