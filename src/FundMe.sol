// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address funder => uint256 amountFounder)
        public addressToAmountFunded;
    address[] public funders;

    uint256 public constant minimum_Usd = 5e18;
    address public immutable owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        //输入参数 priceFeed 取决于要在那条链上
        owner = msg.sender;
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
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public {
        //for loop
        //[1,2,3,4]
        //0,1,2,3,
        // for (/*starting index ,ending index , step amount */)
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //reset the array
        //withdraw the funds
        funders = new address[](0);
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
        if (msg.sender != owner) revert FundMe__NotOwner();
        _;
    }
}
