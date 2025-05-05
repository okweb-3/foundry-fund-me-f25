// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address=> uint256) private s_addressToAmountFunded;
    address[] public s_funders;

    uint256 public constant minimum_Usd = 5e18;
    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        //输入参数 priceFeed 取决于要在那条链上
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        //msg.sender (address): sender of the message (current call)
        //msg.value (uint): number of wei sent with the message
        //msg.value.getConversionRate();
        require(
            msg.value.getConversionRate(s_priceFeed) >= minimum_Usd,
            "did't send enough ETH"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public {
        //for loop
        //[1,2,3,4]
        //0,1,2,3,
        // for (/*starting index ,ending index , step amount */)
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //reset the array
        //withdraw the funds
        s_funders = new address[](0);
        //sending eth from a contract
        //transfer
        //send
        //call

        //transfer
        // payable(msg.sender).transfer(address(this).balance);
        // //send
        // bool sendSuccess =payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"failed to send ETH");
        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    //Solidity function modifider
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    fallback() external payable{
        fund();
    }

    receive() external payable{
        fund();
    }

 // 给外部提供了一个getter方法 从一个 mapping 数据结构中读取该地址对应的资助金额
    function getAddressToAmountFunded(
        address fundingAddress
    )external view returns (uint256){  
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {   
       return s_funders[index] ;   
    }
}
