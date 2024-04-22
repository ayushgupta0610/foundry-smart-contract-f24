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
    address linkTokenAddress;

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
            vrfCoordinatorAddress,
            linkTokenAddress
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

    function testCantEnterWhenRaffleIsCalculating() public raffleEnteredAndTimePassed {
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    // Write them on your own
    function testCheckUpkeepReturnsFalseIfItHasNoBalance() public {
        // Arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        // Act
        (bool upkeepNeeded,) = raffle.checkUpkeep("0x00");

        // Assert
        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnsFalseIfEnoughTimeHasntPassed() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval - 1);
        // vm.roll(block.number + 1);

        // Act
        (bool upkeepNeeded,) = raffle.checkUpkeep("0x00");

        // Assert
        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnsTrueWhenParametersAreGood() public raffleEnteredAndTimePassed {
        // Arranged in the modifier

        // Act
        (bool upkeepNeeded,) = raffle.checkUpkeep("0x00");

        // Assert
        assert(upkeepNeeded);
    }

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public raffleEnteredAndTimePassed {
        // Arranged in the modifier

        // Act / Assert
        raffle.performUpkeep("");
    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        // Arrange
        uint256 currentBalance = 0;
        uint256 playerCount = 0;
        Raffle.RaffleState currentState = Raffle.RaffleState.OPEN;

        // Act / Assert
        vm.expectRevert(abi.encodeWithSelector(
            Raffle.Raffle__RaffleUpkeepNotNeeded.selector,
            currentBalance,
            playerCount,
            currentState
        ));
        raffle.performUpkeep("");
    }

    modifier raffleEnteredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public raffleEnteredAndTimePassed {
        // Arranged in the modifier

        // Act
        vm.recordLogs();
        raffle.performUpkeep("");
        // Vm.Log[] memory entries = vm.getRecordedLogs();
        // bytes32 requestId = entries[1].topics[1];

        // assert(uint256(requestId) > 0);
    }
}