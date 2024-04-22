// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import { CreateSubscription, FundSubscription, AddConsumer } from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle raffle, HelperConfig helperConfig) {
        helperConfig = new HelperConfig();
        // HelperConfig.NetworkConfig memory activeNetworkConfig = helperConfig.activeNetworkConfig;
        (
            uint256 entranceFee,
            uint256 interval,
            bytes32 keyHash,
            uint32 callbackGasLimit,
            uint64 subscriptionId,
            address vrfCoordinatorAddress,
            address linkTokenAddress
        ) = helperConfig.activeNetworkConfig();

        if(subscriptionId == 0) {
            // We're going to need to create a subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinatorAddress);

            // Add consumer (raffle) contract to the subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(vrfCoordinatorAddress, subscriptionId, linkTokenAddress);
        }

        vm.startBroadcast();
        raffle = new Raffle(
            entranceFee,
            interval,
            keyHash,
            callbackGasLimit,
            subscriptionId,
            vrfCoordinatorAddress
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(vrfCoordinatorAddress, address(raffle), subscriptionId);
        return (raffle, helperConfig);
    }
}
