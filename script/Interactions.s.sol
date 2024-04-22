// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { VRFCoordinatorV2Interface } from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint64 subscriptionId) {
        HelperConfig helperConfig = new HelperConfig();
        (,,,,, address vrfCoordinatorAddress) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinatorAddress);
    }

    function createSubscription(address vrfCoordinatorAddress) public returns (uint64 subscriptionId) {
        // Why do we need to put vm.startBroadcast(); here?
        vm.startBroadcast();
        VRFCoordinatorV2Interface vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddress);
        uint64 subId = vrfCoordinator.createSubscription();
        vm.stopBroadcast();
        console.log("Subscription ID: ", subId);
        return subId;
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}