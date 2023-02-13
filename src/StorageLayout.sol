// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";

contract StorageLayout {
    //  *** Reading from slot 0, single slot

    uint256 public slot0 = 100;

    function readSlot0() external returns (uint256) {
        uint256 slot0Value;
        assembly {
            // Load from storage the first slot
            slot0Value := sload(0)
        }

        return slot0Value;
    }

    //  *** Reading from slot 1, shared slot

    uint128 public slot1_0 = 200;
    uint128 public slot1_1 = 250;

    function readSlot1() external returns (uint256, uint256) {
        bytes32 slot0Value;

        assembly {
            // Load from the second slot
            slot0Value := sload(1)
        }

        console.log("Slot 1 value: ");
        console.logBytes32(slot0Value);

        uint128 firstValue;
        uint128 secondValue;
        assembly {
            // Read in the first slot value, automatically cuts off the leading 16 bytes because we read into a uint128
            firstValue := slot0Value
            // Shift the bytes right, so that we get access to the first part of the bytes32 variable (16 bytes * 8 bits = 128)
            secondValue := shr(128, slot0Value)
        }

        return (firstValue, secondValue);
    }

    // **** Dynamic Length

    // Bytes and strings can be treated identically to arrays, they are basically the same anyway

    uint256[] public variableArray = [100, 200, 300, 400, 500];

    // New variables after here are assigned the slot after where the variableArray.length is stored

    function getArray() external returns (uint256[] memory) {
        return variableArray;
    }

    function getArrayLength() external returns (uint256 length) {
        assembly {
            // Load the length using the storage slot of the variableArray
            length := sload(variableArray.slot)
        }

        require(
            variableArray.length == length,
            "You've just embarrased yourself"
        );
    }

    function _getArraySlot(uint256 index) internal returns (bytes32) {
        // Have to use assembly to get access to the variableArray storage slot
        uint256 slot;
        assembly {
            slot := variableArray.slot
        }

        // The base array slot, is a hash of the slot casted to a uint256
        uint256 baseArraySlot = uint256(keccak256(abi.encode(slot)));

        // Then the actual slot for a given element is that base slot + index
        return bytes32(baseArraySlot + index);
    }

    function getArrayItem(uint256 index) external returns (uint256 item) {
        bytes32 slot = _getArraySlot(index);

        assembly {
            item := sload(slot)
        }
    }

    // **** Mappings

    mapping(uint256 => uint256) public testMapping;

    function setupMapping(uint256 numItems) external {
        for (uint256 i = 1; i <= numItems; i++) {
            testMapping[i] = i;
        }
    }

    function _getMappingSlot(uint256 key) internal returns (bytes32 slot) {
        uint256 mappingSlot;
        assembly {
            mappingSlot := testMapping.slot
        }

        return keccak256(abi.encode(key, mappingSlot));
    }

    function getMappingItem(uint256 index) external returns (uint256 item) {
        bytes32 slot = _getMappingSlot(index);

        assembly {
            item := sload(slot)
        }

        console.log("Item: ", item);
    }

    // **** Structs

    struct ExampleStruct {
        uint256 item0;
        uint128 item1_1;
        uint128 item1_2;
    }

    ExampleStruct public exampleStruct;

    function setupStruct() external {
        exampleStruct = ExampleStruct(100, 200, 300);
    }

    function readStructRaw() external returns (ExampleStruct memory) {
        uint256 item0;
        uint128 item1_1;
        uint128 item1_2;

        assembly {
            item0 := sload(exampleStruct.slot)
            item1_1 := sload(add(exampleStruct.slot, 1))
            item1_2 := shr(128, sload(add(exampleStruct.slot, 1)))
        }

        return ExampleStruct(item0, item1_1, item1_2);
    }
}
