//设置让任何一个链上的价格地址都可以访问

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";

contract HelperConfig{
    //设置一个全局变量 给其他合约调用
    NetworkConfig public activeNetworkConfig;

    //如何设置当前网络是活动的网络
    constructor(){
        //利用chainid判断
        if (block.chainid== 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        }else if (block.chainid == 1){
            activeNetworkConfig =getMainnetEthConfig();
        }else{
            activeNetworkConfig =getAnvilEthConfig();
        }
    }

    //写一个网络配置的结构体
    struct NetworkConfig {
        address priceFeed; // ETH/USD 价格转换数据源
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //数据源地址
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }
    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //数据源地址
         NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return ethConfig;
    }  
     function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
        //数据源地址
    }  

}