// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether; // Same as 1e16

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        fundFundMe(mostRecentlyDeployed);
    }

    function fundFundMe(address mostRecentlyDeployed) public {
        FundMe fundMe = FundMe(payable(mostRecentlyDeployed));
        vm.startBroadcast();
        fundMe.fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe contract with %d", SEND_VALUE);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether; // Same as 1e16

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        withdrawFundMe(mostRecentlyDeployed);
    }

    function withdrawFundMe(address mostRecentlyDeployed) public {
        FundMe fundMe = FundMe(payable(mostRecentlyDeployed));
        vm.startBroadcast();
        fundMe.withdraw();
        vm.stopBroadcast();
        console.log("FundMe contract balance withdrawn!");
    }
}
