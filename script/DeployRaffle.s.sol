// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import { CreateSubscription } from "./Interactions.s.sol";

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
            address vrfCoordinatorAddress
        ) = helperConfig.activeNetworkConfig();

        if(subscriptionId == 0) {
            // We're going to need to create a subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinatorAddress);
        }

        raffle = new Raffle(
            entranceFee,
            interval,
            keyHash,
            callbackGasLimit,
            subscriptionId,
            vrfCoordinatorAddress
        );
        return (raffle, helperConfig);
    }
}
