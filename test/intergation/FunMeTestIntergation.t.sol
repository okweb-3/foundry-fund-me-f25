// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../src/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1;

    address USER1 = makeAddr("user1");
    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER1, START_BALANCE);
    }
    function testUserCanFundInteractions() public {
        uint256 preUserBalance = address(USER1).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(USER1);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(USER1).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
    }
    function testUserCanFundMeInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        //没充值导致测试不过去
        vm.deal(address(fundFundMe), START_BALANCE);
        fundFundMe.fundFundMe(address(fundMe));
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
    }
}
