//设置让任何一个链上的价格地址都可以访问

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //设置一个全局变量 给其他合约调用
    NetworkConfig public activeNetworkConfig;

    //给下面的模拟地址用
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    //如何设置当前网络是活动的网络
    constructor() {
        //利用chainid判断
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreatAnvilEthConfig();
        }
    }
    //写一个网络配置的结构体
    struct NetworkConfig {
        address priceFeed; // ETH/USD 价格转换数据源
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //数据源地址
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }
    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //数据源地址
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return ethConfig;
    }
    function getOrCreatAnvilEthConfig() public returns (NetworkConfig memory) {
        //如果已经设置了网络配置，则返回现有的。
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; 
        }

        //数据源地址
        //部署模拟合同
        //返回模拟合同地址
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
