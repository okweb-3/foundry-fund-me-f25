// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1;
    //创建一个测试地址，让所有信息都从这个地址发送
    address USER = makeAddr("user");

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
        assertEq(fundMe.getOwner(), msg.sender);
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
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); //表示我们预期接下来的一行代码会抛出异常（即 revert）。如果没有 revert，则测试失败。
        fundMe.withdraw();
    }

    /*
        测试的三个阶段
        1.Arrange 准备阶段 创建对象 变量和测试数据
        2.Act 触发操作 调用函数并验证结果
        3.Assert 断言阶段  验证结果是否符合预期
    */
    function testWithDrawWithASingleFunder() public funded {
        //Arrange  检查取款之前的余额
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        console.log("starting owner balance: ", startingOwnerBalance);
        console.log("starting FundMe balance: ", startingFundMeBalance);

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank 伪造一个新地址
            //vm.deal
            address funder = vm.addr(i); // 伪造的地址，用 i 做种子
            hoax(funder, SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            //fund the fundMe
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        // vm.prank(fundMe.getOwner());
        // funderMe.withdraw();
        //和下面的等价
        // 执行前剩余 gas
        uint256 gasStart = gasleft();
        //设置交易为1wei
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        // 执行后剩余 gas
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //当前交易的 gas price，单位是 wei，把 gas 消耗乘以价格，得到真实费用
        console.log("gas used: ", gasUsed);

        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
    function testWithdrawFromMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank 伪造一个新地址
            //vm.deal
            address funder = vm.addr(i); // 伪造的地址，用 i 做种子
            hoax(funder, SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            //fund the fundMe
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        // vm.prank(fundMe.getOwner());
        // funderMe.withdraw();
        //和下面的等价
        // 执行前剩余 gas
        uint256 gasStart = gasleft();
        //设置交易为1wei
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.CheaperWithdraw();
        vm.stopPrank();
        // 执行后剩余 gas
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //当前交易的 gas price，单位是 wei，把 gas 消耗乘以价格，得到真实费用
        console.log("gas used: ", gasUsed);

        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
