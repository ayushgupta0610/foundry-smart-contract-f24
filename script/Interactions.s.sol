// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { VRFCoordinatorV2Mock } from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import { LinkToken } from "../test/mocks/LinkToken.sol";
import { DevOpsTools } from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint64 subscriptionId) {
        HelperConfig helperConfig = new HelperConfig();
        (,,,,, address vrfCoordinatorAddress,, uint256 deployerKey) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinatorAddress, deployerKey);
    }

    function createSubscription(address vrfCoordinatorAddress, uint256 deployerKey) public returns (uint64 subscriptionId) {
        // Why do we need to put vm.startBroadcast(); here?
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock vrfCoordinator = VRFCoordinatorV2Mock(vrfCoordinatorAddress);
        uint64 subId = vrfCoordinator.createSubscription();
        vm.stopBroadcast();
        console.log("Subscription ID: ", subId);
        return subId;
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {

    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
         HelperConfig helperConfig = new HelperConfig();
        (,,,, uint64 subId, address vrfCoordinatorAddress, address linkTokenAddress, uint256 deployerKey) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinatorAddress, subId, linkTokenAddress, deployerKey);
    }

    function fundSubscription(address vrfCoordinatorAddress, uint64 subId, address linkTokenAddress, uint256 deployerKey) public {
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock vrfCoordinator = VRFCoordinatorV2Mock(vrfCoordinatorAddress);
        // If we're on local chain (anvil)
        if (block.chainid == 31337) {
            // Fund the subscription
            vrfCoordinator.fundSubscription(subId, FUND_AMOUNT);
        } else {
            // Fund the subscription
            LinkToken(linkTokenAddress).transferAndCall(vrfCoordinatorAddress, FUND_AMOUNT, abi.encode(subId));
        }
        vm.stopBroadcast();
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address raffleAddress) public {
        HelperConfig helperConfig = new HelperConfig();
        (,,,, uint64 subId, address vrfCoordinatorAddress,, uint256 deployerKey) = helperConfig.activeNetworkConfig();
        addConsumer(vrfCoordinatorAddress, raffleAddress, subId, deployerKey);
    }

    function addConsumer(address vrfCoordinatorAddress, address consumerAddress, uint64 subId, uint256 deployerKey) public {
        VRFCoordinatorV2Mock vrfCoordinator = VRFCoordinatorV2Mock(vrfCoordinatorAddress);
        vm.startBroadcast(deployerKey);
        vrfCoordinator.addConsumer(subId, consumerAddress);
        vm.stopBroadcast();
    }

    function run() external {
        address raffleAddress = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(raffleAddress);
    }
}