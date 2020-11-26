{{
  "language": "Solidity",
  "sources": {
    "/Users/0x/0x-monorepo/contracts/asset-proxy/contracts/src/StaticCallProxy.sol": {
      "content": "/*\n\n  Copyright 2018 ZeroEx Intl.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\");\n  you may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n    http://www.apache.org/licenses/LICENSE-2.0\n\n  Unless required by applicable law or agreed to in writing, software\n  distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions and\n  limitations under the License.\n\n*/\n\npragma solidity ^0.5.9;\n\nlibrary LibBytes {\n\n    using LibBytes for bytes;\n\n    /// @dev Gets the memory address for a byte array.\n    /// @param input Byte array to lookup.\n    /// @return memoryAddress Memory address of byte array. This\n    ///         points to the header of the byte array which contains\n    ///         the length.\n    function rawAddress(bytes memory input)\n        internal\n        pure\n        returns (uint256 memoryAddress)\n    {\n        assembly {\n            memoryAddress := input\n        }\n        return memoryAddress;\n    }\n    \n    /// @dev Gets the memory address for the contents of a byte array.\n    /// @param input Byte array to lookup.\n    /// @return memoryAddress Memory address of the contents of the byte array.\n    function contentAddress(bytes memory input)\n        internal\n        pure\n        returns (uint256 memoryAddress)\n    {\n        assembly {\n            memoryAddress := add(input, 32)\n        }\n        return memoryAddress;\n    }\n\n    /// @dev Copies `length` bytes from memory location `source` to `dest`.\n    /// @param dest memory address to copy bytes to.\n    /// @param source memory address to copy bytes from.\n    /// @param length number of bytes to copy.\n    function memCopy(\n        uint256 dest,\n        uint256 source,\n        uint256 length\n    )\n        internal\n        pure\n    {\n        if (length < 32) {\n            // Handle a partial word by reading destination and masking\n            // off the bits we are interested in.\n            // This correctly handles overlap, zero lengths and source == dest\n            assembly {\n                let mask := sub(exp(256, sub(32, length)), 1)\n                let s := and(mload(source), not(mask))\n                let d := and(mload(dest), mask)\n                mstore(dest, or(s, d))\n            }\n        } else {\n            // Skip the O(length) loop when source == dest.\n            if (source == dest) {\n                return;\n            }\n\n            // For large copies we copy whole words at a time. The final\n            // word is aligned to the end of the range (instead of after the\n            // previous) to handle partial words. So a copy will look like this:\n            //\n            //  ####\n            //      ####\n            //          ####\n            //            ####\n            //\n            // We handle overlap in the source and destination range by\n            // changing the copying direction. This prevents us from\n            // overwriting parts of source that we still need to copy.\n            //\n            // This correctly handles source == dest\n            //\n            if (source > dest) {\n                assembly {\n                    // We subtract 32 from `sEnd` and `dEnd` because it\n                    // is easier to compare with in the loop, and these\n                    // are also the addresses we need for copying the\n                    // last bytes.\n                    length := sub(length, 32)\n                    let sEnd := add(source, length)\n                    let dEnd := add(dest, length)\n\n                    // Remember the last 32 bytes of source\n                    // This needs to be done here and not after the loop\n                    // because we may have overwritten the last bytes in\n                    // source already due to overlap.\n                    let last := mload(sEnd)\n\n                    // Copy whole words front to back\n                    // Note: the first check is always true,\n                    // this could have been a do-while loop.\n                    // solhint-disable-next-line no-empty-blocks\n                    for {} lt(source, sEnd) {} {\n                        mstore(dest, mload(source))\n                        source := add(source, 32)\n                        dest := add(dest, 32)\n                    }\n                    \n                    // Write the last 32 bytes\n                    mstore(dEnd, last)\n                }\n            } else {\n                assembly {\n                    // We subtract 32 from `sEnd` and `dEnd` because those\n                    // are the starting points when copying a word at the end.\n                    length := sub(length, 32)\n                    let sEnd := add(source, length)\n                    let dEnd := add(dest, length)\n\n                    // Remember the first 32 bytes of source\n                    // This needs to be done here and not after the loop\n                    // because we may have overwritten the first bytes in\n                    // source already due to overlap.\n                    let first := mload(source)\n\n                    // Copy whole words back to front\n                    // We use a signed comparisson here to allow dEnd to become\n                    // negative (happens when source and dest < 32). Valid\n                    // addresses in local memory will never be larger than\n                    // 2**255, so they can be safely re-interpreted as signed.\n                    // Note: the first check is always true,\n                    // this could have been a do-while loop.\n                    // solhint-disable-next-line no-empty-blocks\n                    for {} slt(dest, dEnd) {} {\n                        mstore(dEnd, mload(sEnd))\n                        sEnd := sub(sEnd, 32)\n                        dEnd := sub(dEnd, 32)\n                    }\n                    \n                    // Write the first 32 bytes\n                    mstore(dest, first)\n                }\n            }\n        }\n    }\n\n    /// @dev Returns a slices from a byte array.\n    /// @param b The byte array to take a slice from.\n    /// @param from The starting index for the slice (inclusive).\n    /// @param to The final index for the slice (exclusive).\n    /// @return result The slice containing bytes at indices [from, to)\n    function slice(\n        bytes memory b,\n        uint256 from,\n        uint256 to\n    )\n        internal\n        pure\n        returns (bytes memory result)\n    {\n        require(\n            from <= to,\n            \"FROM_LESS_THAN_TO_REQUIRED\"\n        );\n        require(\n            to <= b.length,\n            \"TO_LESS_THAN_LENGTH_REQUIRED\"\n        );\n        \n        // Create a new bytes structure and copy contents\n        result = new bytes(to - from);\n        memCopy(\n            result.contentAddress(),\n            b.contentAddress() + from,\n            result.length\n        );\n        return result;\n    }\n    \n    /// @dev Returns a slice from a byte array without preserving the input.\n    /// @param b The byte array to take a slice from. Will be destroyed in the process.\n    /// @param from The starting index for the slice (inclusive).\n    /// @param to The final index for the slice (exclusive).\n    /// @return result The slice containing bytes at indices [from, to)\n    /// @dev When `from == 0`, the original array will match the slice. In other cases its state will be corrupted.\n    function sliceDestructive(\n        bytes memory b,\n        uint256 from,\n        uint256 to\n    )\n        internal\n        pure\n        returns (bytes memory result)\n    {\n        require(\n            from <= to,\n            \"FROM_LESS_THAN_TO_REQUIRED\"\n        );\n        require(\n            to <= b.length,\n            \"TO_LESS_THAN_LENGTH_REQUIRED\"\n        );\n        \n        // Create a new bytes structure around [from, to) in-place.\n        assembly {\n            result := add(b, from)\n            mstore(result, sub(to, from))\n        }\n        return result;\n    }\n\n    /// @dev Pops the last byte off of a byte array by modifying its length.\n    /// @param b Byte array that will be modified.\n    /// @return The byte that was popped off.\n    function popLastByte(bytes memory b)\n        internal\n        pure\n        returns (bytes1 result)\n    {\n        require(\n            b.length > 0,\n            \"GREATER_THAN_ZERO_LENGTH_REQUIRED\"\n        );\n\n        // Store last byte.\n        result = b[b.length - 1];\n\n        assembly {\n            // Decrement length of byte array.\n            let newLen := sub(mload(b), 1)\n            mstore(b, newLen)\n        }\n        return result;\n    }\n\n    /// @dev Pops the last 20 bytes off of a byte array by modifying its length.\n    /// @param b Byte array that will be modified.\n    /// @return The 20 byte address that was popped off.\n    function popLast20Bytes(bytes memory b)\n        internal\n        pure\n        returns (address result)\n    {\n        require(\n            b.length >= 20,\n            \"GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED\"\n        );\n\n        // Store last 20 bytes.\n        result = readAddress(b, b.length - 20);\n\n        assembly {\n            // Subtract 20 from byte array length.\n            let newLen := sub(mload(b), 20)\n            mstore(b, newLen)\n        }\n        return result;\n    }\n\n    /// @dev Tests equality of two byte arrays.\n    /// @param lhs First byte array to compare.\n    /// @param rhs Second byte array to compare.\n    /// @return True if arrays are the same. False otherwise.\n    function equals(\n        bytes memory lhs,\n        bytes memory rhs\n    )\n        internal\n        pure\n        returns (bool equal)\n    {\n        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.\n        // We early exit on unequal lengths, but keccak would also correctly\n        // handle this.\n        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);\n    }\n\n    /// @dev Reads an address from a position in a byte array.\n    /// @param b Byte array containing an address.\n    /// @param index Index in byte array of address.\n    /// @return address from byte array.\n    function readAddress(\n        bytes memory b,\n        uint256 index\n    )\n        internal\n        pure\n        returns (address result)\n    {\n        require(\n            b.length >= index + 20,  // 20 is length of address\n            \"GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED\"\n        );\n\n        // Add offset to index:\n        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)\n        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)\n        index += 20;\n\n        // Read address from array memory\n        assembly {\n            // 1. Add index to address of bytes array\n            // 2. Load 32-byte word from memory\n            // 3. Apply 20-byte mask to obtain address\n            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)\n        }\n        return result;\n    }\n\n    /// @dev Writes an address into a specific position in a byte array.\n    /// @param b Byte array to insert address into.\n    /// @param index Index in byte array of address.\n    /// @param input Address to put into byte array.\n    function writeAddress(\n        bytes memory b,\n        uint256 index,\n        address input\n    )\n        internal\n        pure\n    {\n        require(\n            b.length >= index + 20,  // 20 is length of address\n            \"GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED\"\n        );\n\n        // Add offset to index:\n        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)\n        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)\n        index += 20;\n\n        // Store address into array memory\n        assembly {\n            // The address occupies 20 bytes and mstore stores 32 bytes.\n            // First fetch the 32-byte word where we'll be storing the address, then\n            // apply a mask so we have only the bytes in the word that the address will not occupy.\n            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.\n\n            // 1. Add index to address of bytes array\n            // 2. Load 32-byte word from memory\n            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address\n            let neighbors := and(\n                mload(add(b, index)),\n                0xffffffffffffffffffffffff0000000000000000000000000000000000000000\n            )\n            \n            // Make sure input address is clean.\n            // (Solidity does not guarantee this)\n            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)\n\n            // Store the neighbors and address into memory\n            mstore(add(b, index), xor(input, neighbors))\n        }\n    }\n\n    /// @dev Reads a bytes32 value from a position in a byte array.\n    /// @param b Byte array containing a bytes32 value.\n    /// @param index Index in byte array of bytes32 value.\n    /// @return bytes32 value from byte array.\n    function readBytes32(\n        bytes memory b,\n        uint256 index\n    )\n        internal\n        pure\n        returns (bytes32 result)\n    {\n        require(\n            b.length >= index + 32,\n            \"GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED\"\n        );\n\n        // Arrays are prefixed by a 256 bit length parameter\n        index += 32;\n\n        // Read the bytes32 from array memory\n        assembly {\n            result := mload(add(b, index))\n        }\n        return result;\n    }\n\n    /// @dev Writes a bytes32 into a specific position in a byte array.\n    /// @param b Byte array to insert <input> into.\n    /// @param index Index in byte array of <input>.\n    /// @param input bytes32 to put into byte array.\n    function writeBytes32(\n        bytes memory b,\n        uint256 index,\n        bytes32 input\n    )\n        internal\n        pure\n    {\n        require(\n            b.length >= index + 32,\n            \"GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED\"\n        );\n\n        // Arrays are prefixed by a 256 bit length parameter\n        index += 32;\n\n        // Read the bytes32 from array memory\n        assembly {\n            mstore(add(b, index), input)\n        }\n    }\n\n    /// @dev Reads a uint256 value from a position in a byte array.\n    /// @param b Byte array containing a uint256 value.\n    /// @param index Index in byte array of uint256 value.\n    /// @return uint256 value from byte array.\n    function readUint256(\n        bytes memory b,\n        uint256 index\n    )\n        internal\n        pure\n        returns (uint256 result)\n    {\n        result = uint256(readBytes32(b, index));\n        return result;\n    }\n\n    /// @dev Writes a uint256 into a specific position in a byte array.\n    /// @param b Byte array to insert <input> into.\n    /// @param index Index in byte array of <input>.\n    /// @param input uint256 to put into byte array.\n    function writeUint256(\n        bytes memory b,\n        uint256 index,\n        uint256 input\n    )\n        internal\n        pure\n    {\n        writeBytes32(b, index, bytes32(input));\n    }\n\n    /// @dev Reads an unpadded bytes4 value from a position in a byte array.\n    /// @param b Byte array containing a bytes4 value.\n    /// @param index Index in byte array of bytes4 value.\n    /// @return bytes4 value from byte array.\n    function readBytes4(\n        bytes memory b,\n        uint256 index\n    )\n        internal\n        pure\n        returns (bytes4 result)\n    {\n        require(\n            b.length >= index + 4,\n            \"GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED\"\n        );\n\n        // Arrays are prefixed by a 32 byte length field\n        index += 32;\n\n        // Read the bytes4 from array memory\n        assembly {\n            result := mload(add(b, index))\n            // Solidity does not require us to clean the trailing bytes.\n            // We do it anyway\n            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)\n        }\n        return result;\n    }\n\n    /// @dev Reads nested bytes from a specific position.\n    /// @dev NOTE: the returned value overlaps with the input value.\n    ///            Both should be treated as immutable.\n    /// @param b Byte array containing nested bytes.\n    /// @param index Index of nested bytes.\n    /// @return result Nested bytes.\n    function readBytesWithLength(\n        bytes memory b,\n        uint256 index\n    )\n        internal\n        pure\n        returns (bytes memory result)\n    {\n        // Read length of nested bytes\n        uint256 nestedBytesLength = readUint256(b, index);\n        index += 32;\n\n        // Assert length of <b> is valid, given\n        // length of nested bytes\n        require(\n            b.length >= index + nestedBytesLength,\n            \"GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED\"\n        );\n        \n        // Return a pointer to the byte array as it exists inside `b`\n        assembly {\n            result := add(b, index)\n        }\n        return result;\n    }\n\n    /// @dev Inserts bytes at a specific position in a byte array.\n    /// @param b Byte array to insert <input> into.\n    /// @param index Index in byte array of <input>.\n    /// @param input bytes to insert.\n    function writeBytesWithLength(\n        bytes memory b,\n        uint256 index,\n        bytes memory input\n    )\n        internal\n        pure\n    {\n        // Assert length of <b> is valid, given\n        // length of input\n        require(\n            b.length >= index + 32 + input.length,  // 32 bytes to store length\n            \"GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED\"\n        );\n\n        // Copy <input> into <b>\n        memCopy(\n            b.contentAddress() + index,\n            input.rawAddress(), // includes length of <input>\n            input.length + 32   // +32 bytes to store <input> length\n        );\n    }\n\n    /// @dev Performs a deep copy of a byte array onto another byte array of greater than or equal length.\n    /// @param dest Byte array that will be overwritten with source bytes.\n    /// @param source Byte array to copy onto dest bytes.\n    function deepCopyBytes(\n        bytes memory dest,\n        bytes memory source\n    )\n        internal\n        pure\n    {\n        uint256 sourceLen = source.length;\n        // Dest length must be >= source length, or some bytes would not be copied.\n        require(\n            dest.length >= sourceLen,\n            \"GREATER_OR_EQUAL_TO_SOURCE_BYTES_LENGTH_REQUIRED\"\n        );\n        memCopy(\n            dest.contentAddress(),\n            source.contentAddress(),\n            sourceLen\n        );\n    }\n}\n\n// solhint-disable no-unused-vars\ncontract StaticCallProxy {\n\n    using LibBytes for bytes;\n\n    // Id of this proxy.\n    bytes4 constant internal PROXY_ID = bytes4(keccak256(\"StaticCall(address,bytes,bytes32)\"));\n\n    /// @dev Makes a staticcall to a target address and verifies that the data returned matches the expected return data.\n    /// @param assetData Byte array encoded with staticCallTarget, staticCallData, and expectedCallResultHash\n    /// @param from This value is ignored.\n    /// @param to This value is ignored.\n    /// @param amount This value is ignored.\n    function transferFrom(\n        bytes calldata assetData,\n        address from,\n        address to,\n        uint256 amount\n    )\n        external\n        view\n    {\n        // Decode params from `assetData`\n        (\n            address staticCallTarget,\n            bytes memory staticCallData,\n            bytes32 expectedReturnDataHash\n        ) = abi.decode(\n            assetData.sliceDestructive(4, assetData.length),\n            (address, bytes, bytes32)\n        );\n\n        // Execute staticcall\n        (bool success, bytes memory returnData) = staticCallTarget.staticcall(staticCallData);\n\n        // Revert with returned data if staticcall is unsuccessful\n        if (!success) {\n            assembly {\n                revert(add(returnData, 32), mload(returnData))\n            }\n        }\n\n        // Revert if hash of return data is not as expected\n        bytes32 returnDataHash = keccak256(returnData);\n        require(\n            expectedReturnDataHash == returnDataHash,\n            \"UNEXPECTED_STATIC_CALL_RESULT\"\n        );\n    }\n\n    /// @dev Gets the proxy id associated with the proxy address.\n    /// @return Proxy id.\n    function getProxyId()\n        external\n        pure\n        returns (bytes4)\n    {\n        return PROXY_ID;\n    }\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 1000000,
      "details": {
        "yul": true,
        "deduplicate": true,
        "cse": true,
        "constantOptimizer": true
      }
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    },
    "evmVersion": "constantinople",
    "remappings": []
  }
}}