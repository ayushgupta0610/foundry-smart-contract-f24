// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { Raffle } from "../src/Raffle.sol";
import { HelperConfig } from "../script/HelperConfig.s.sol";
import { DeployRaffle } from "../script/DeployRaffle.s.sol";

contract RaffleTest is Test {

    event EnteredRaffle(address indexed player);

    Raffle raffle;
    HelperConfig helperConfig;

    address immutable PLAYER = makeAddr("PLAYER");
    uint256 constant STARTING_BALANCE = 100 ether;

    uint256 entranceFee;
    uint256 interval;
    bytes32 keyHash;
    uint32 callbackGasLimit;
    uint64 subscriptionId;
    address vrfCoordinatorAddress;

    function setUp() public {
        // Set up state variables
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig)  = deployRaffle.run();

        // Set up the helper config as the state in the test contract
        (
            entranceFee,
            interval,
            keyHash,
            callbackGasLimit,
            subscriptionId,
            vrfCoordinatorAddress
        ) = helperConfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_BALANCE);
    }

    function testInitialiseRaffle() public {
        // Check if the raffle is initialised
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEmitsEventOnEntrance() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testEnterRaffle() public {

    }

    function testPickWinner() public {

    }
}