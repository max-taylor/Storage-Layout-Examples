// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/StorageLayout.sol";

contract CounterTest is Test {
    StorageLayout public storageLayout;

    function setUp() public {
        storageLayout = new StorageLayout();
    }

    function testSlot0() public {
        assertEq(storageLayout.slot0(), storageLayout.readSlot0());
    }

    function testSlot1() public {
        (uint256 firstValue, uint256 secondValue) = storageLayout.readSlot1();

        assertEq(storageLayout.slot1_0(), firstValue);
        assertEq(storageLayout.slot1_1(), secondValue);
    }

    function testArrayLength() public {
        uint256[] memory array = storageLayout.getArray();

        // Hardcoded 5 items to the array
        assertEq(storageLayout.getArrayLength(), array.length);
    }

    function testArrayItems() public {
        uint256[] memory array = storageLayout.getArray();

        for (uint256 i = 0; i < array.length; i++) {
            assertEq(storageLayout.getArrayItem(i), array[i]);
        }
    }

    function testMappingItems() public {
        uint256 numItems = 5;
        storageLayout.setupMapping(numItems);

        for (uint256 i = 1; i <= numItems; i++) {
            assertEq(storageLayout.getMappingItem(i), i);
        }
    }

    function testStruct() public {
        storageLayout.setupStruct();

        (uint256 item0, uint256 item1_1, uint256 item1_2) = storageLayout
            .exampleStruct();

        StorageLayout.ExampleStruct memory rawReadStruct = storageLayout
            .readStructRaw();

        assertEq(item0, rawReadStruct.item0);
        assertEq(item1_1, rawReadStruct.item1_1);
        assertEq(item1_2, rawReadStruct.item1_2);
    }
}
