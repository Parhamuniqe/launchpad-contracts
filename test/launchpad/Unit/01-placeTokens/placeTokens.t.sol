// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25;

import {BaseLaunchpadTest, Launchpad, ILaunchpad} from "../../BaseLaunchpad.t.sol";

contract PlaceTokensTest is BaseLaunchpadTest {
    function test_placeTokens() public {
        uint256 nowTimestamp = block.timestamp;
        uint256 initialVolume = 100 * 10 ** 18;
        uint256 initialVolumeForHighTiers = initialVolume * 60 / 100;
        uint256 initialVolumeForLowTiers = initialVolume * 20 / 100;
        uint256 initialVolumeForYieldStakers = initialVolume * 20 / 100;
        address addressForCollected = address(2);
        uint256 timeOfEndRegistration = nowTimestamp + 600;
        uint256 price = 10 ** 18;
        uint256 vestingDuration = 60;
        uint8 tgePercent = 15;

        ILaunchpad.PlaceTokensInput memory input = ILaunchpad.PlaceTokensInput({
            price: price,
            token: address(testToken),
            initialVolumeForHighTiers: initialVolumeForHighTiers,
            initialVolumeForLowTiers: initialVolumeForLowTiers,
            initialVolumeForYieldStakers: initialVolumeForYieldStakers,
            timeOfEndRegistration: timeOfEndRegistration,
            addressForCollected: addressForCollected,
            vestingDuration: vestingDuration,
            tgePercent: tgePercent
        });

        vm.startPrank(admin);
        testToken.mint(admin, 100 * 10 ** 19);
        testToken.approve(address(launchpad), type(uint256).max);
        launchpad.placeTokens(input);

        (
            uint256 test_price,
            uint256 test_volumeForYieldStakers,
            uint256 test_volumeForLowTiers,
            uint256 test_volumeForHighTiers,
            uint256 test_initialVolumeForLowTiers,
            uint256 test_initialVolumeForHighTiers,
            uint256 test_lowTiersWeightsSum,
            uint256 test_highTiersWeightsSum,
            uint8 test_tokenDecimals,
            address test_addressForCollected,
            ILaunchpad.SaleStatus test_status,
            uint256 test_currentStateEnd,
            uint256 test_vestingStartTimestamp,
            uint256 test_vestingDuration,
            uint256 test_tgeTimestamp,
            uint8 test_tgePercent
        ) = launchpad.placedTokens(address(testToken));

        assertEq(testToken.balanceOf(address(launchpad)), initialVolume);
        assertEq(test_price, price);
        assertEq(test_volumeForYieldStakers, initialVolumeForYieldStakers);
        assertEq(test_tokenDecimals, 18);

        vm.expectRevert("BlastUP: This token was already placed");

        launchpad.placeTokens(input);

        input.token = address(testToken2);
        input.initialVolumeForHighTiers = 0;
        input.initialVolumeForLowTiers = 0;
        input.initialVolumeForYieldStakers = 0;

        vm.expectRevert("BlastUP: initial Volume must be > 0");

        launchpad.placeTokens(input);

        vm.stopPrank();
    }
}