// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    MockV3Aggregator public mockV3Aggregator;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;

    constructor() {
        if (block.chainid == 1) {
            activeNetworkConfig = getEthMainnetConfig();
        } else if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethMainnetConfig = NetworkConfig({priceFeed: 0xb49f677943BC038e9857d61E7d053CaA2C1734C1});
        return ethMainnetConfig;
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockV3Aggregator)});

        return anvilConfig;
    }
}
