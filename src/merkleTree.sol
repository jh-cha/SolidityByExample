// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf,
        uint index
    ) public pure returns (bool) {
        bytes32 hash = leaf;

        for (uint i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }

            index = index / 2;
        }

        return hash == root;
    }
}

contract TestMerkleProof is MerkleProof {
    event hash(string inputTx, bytes32 hash);
    event merkleHash(bytes32 tx1, bytes32 tx2, bytes32 merkleHash);
    bytes32[] public hashes;

    constructor() {
        string[4] memory transactions = [
            "alice -> bob",
            "bob -> dave",
            "carol -> alice",
            "dave -> bob"
        ];

        for (uint i = 0; i < transactions.length; i++) {
            // encodePacked 확인필요
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
            emit hash(transactions[i], keccak256(abi.encodePacked(transactions[i])));
        }

        uint n = transactions.length;
        uint offset = 0;

        while (n > 0) {
            for (uint i = 0; i < n - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                    )
                );
                emit merkleHash(
                    hashes[offset + i],
                    hashes[offset + i + 1],
                    keccak256(
                        abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }

    /* verify
    3rd leaf
    0xdca3326ad7e8121bf9cf9c12333e6b2271abe823ec9edfe42f813b1e768fa57b

    root
    0xcc086fcc038189b4641db2cc4f1de3bb132aefbd65d510d817591550937818c7

    index
    2

    proof
    0x8da9e1c820f9dbd1589fd6585872bc1063588625729e7ab0797cfc63a00bd950
    0x995788ffc103b987ad50f5e5707fd094419eb12d9552cc423bd0cd86a3861433
    */

    /*
        "alice -> bob", hash => 0x78a93af7ef9f1380d64a61c552cbefc298da07acb65530265b8ade6ebe8218c4
        "bob -> dave", hash => 0x92ae03b807c62726370a4dcfecf582930f7fbb404217356b6160b587720d3ba7
        "carol -> alice", hash => 0xdca3326ad7e8121bf9cf9c12333e6b2271abe823ec9edfe42f813b1e768fa57b
        "dave -> bob" hash => 0x8da9e1c820f9dbd1589fd6585872bc1063588625729e7ab0797cfc63a00bd950
    */
    function getHash(string calldata inputTx) public pure returns (bytes32){
        return keccak256(abi.encode(inputTx));
    }

    /*
        0x78a93af7ef9f1380d64a61c552cbefc298da07acb65530265b8ade6ebe8218c4
        0x92ae03b807c62726370a4dcfecf582930f7fbb404217356b6160b587720d3ba7
        => 0x995788ffc103b987ad50f5e5707fd094419eb12d9552cc423bd0cd86a3861433

        0xdca3326ad7e8121bf9cf9c12333e6b2271abe823ec9edfe42f813b1e768fa57b
        0x8da9e1c820f9dbd1589fd6585872bc1063588625729e7ab0797cfc63a00bd950
        => 0x2f71627ef88774789455f181c533a6f7a68fe16e76e7a50362af377269aabfee

        0x995788ffc103b987ad50f5e5707fd094419eb12d9552cc423bd0cd86a3861433
        0x2f71627ef88774789455f181c533a6f7a68fe16e76e7a50362af377269aabfee
        => 0xcc086fcc038189b4641db2cc4f1de3bb132aefbd65d510d817591550937818c7
    */
    function getMerkleHash(bytes32 _tx1, bytes32 _tx2) public pure returns (bytes32){
        return keccak256(abi.encodePacked(_tx1, _tx2));
    }
}