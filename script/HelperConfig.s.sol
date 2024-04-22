// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { VRFCoordinatorV2Mock } from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import { LinkToken } from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {


    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        bytes32 keyHash;
        uint32 callbackGasLimit;
        uint64 subscriptionId;
        address vrfCoordinatorAddress;
        address linkTokenAddress;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory networkConfig) {
        networkConfig = NetworkConfig({
            entranceFee: 0.1 ether,
            interval: 1 days,
            keyHash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit: 150,
            subscriptionId: 11281,
            vrfCoordinatorAddress: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            linkTokenAddress: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    // This should be capable enough to allow us to run our Raffle contract on the local testnet as well
    // That is, from getting the automation to creating a mock random number
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory networkConfig) {
        if(activeNetworkConfig.vrfCoordinatorAddress != address(0)) {
            return activeNetworkConfig;
        }
        // On anvil testnet, we don't have vrfCoordinatorAddress to create a random number
        // Does keyHash matter on the anvil testnet? If yes, how do we get it in here.

        uint96 baseFee = .25 ether;
        uint96 gasPriceLink = 10**9;

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinator = new VRFCoordinatorV2Mock(
            baseFee, 
            gasPriceLink
        );
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        networkConfig = NetworkConfig({
            entranceFee: 0.1 ether,
            interval: 1 days,
            keyHash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit: 150,
            subscriptionId: 11281,
            vrfCoordinatorAddress: address(vrfCoordinator),
            linkTokenAddress: address(linkToken)
        });
    }
}