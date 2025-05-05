// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    
    uint256 constant SEND_VALUE = 0.1 ether; 
    uint256 constant START_BALANCE = 100 ether;
    //创建一个测试地址，让所有信息都从这个地址发送
    address USER=makeAddr("user");

    function setUp() external {
        //先运行
        //number = 2;
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //给测试地址打点钱
        vm.deal(USER, START_BALANCE); 
    }

    function testMinimunDollarIsFive() public {
        assertEq(fundMe.minimum_Usd(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        //us->FunderMeTest->Fundme
        assertEq(fundMe.i_owner(), msg.sender);
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
    function testFundFailsWithOutEnoughETH() public {
        vm.expectRevert(); //下一行代码即使是无法执行的，也能正常测试通过
        fundMe.fund(); //发送了0ETH
    }
    function testFundUpdatesFundedDataStruct() public { 
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq (amountFunded,SEND_VALUE); 
    }

}
