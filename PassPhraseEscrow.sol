// money deposited + set passphrase
// user with passphrase can withdraw money

// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract PassPhraseEscrow {


    // struct Data {
    //     bytes32 hashedPassPhrase;
    //     uint256 amount;
    // }

    mapping(bytes32 => uint256) public amountMapping;

    function depositEth(
        bytes32 _hashedPassPhrase
    ) external payable {
        amountMapping[_hashedPassPhrase] = msg.value;
    }

    // user => hashedPassPhrase
    mapping(address => bytes) public whitelistMap;

    // sign -> passPhrase

    function firstTxn(
        bytes memory _signature
    ) external {
        whitelistMap[msg.sender] = _signature;
    }

    function secondTxn(
        string memory _passPhrase
    ) external {
        // compute digest
        bytes32 digest = keccak256(abi.encodePacked(_passPhrase));
        bytes32 messageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", digest)
        );
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(whitelistMap[msg.sender]);
        address signer = ecrecover(messageHash, v, r, s);

        if(signer != msg.sender) {
            revert();
        }

        bytes32 computedHashedPhrase = keccak256(abi.encodePacked(_passPhrase));
        if(amountMapping[computedHashedPhrase] > 0) {
            amountMapping[computedHashedPhrase] = 0;
            (bool success, ) = msg.sender.call{ value: amountMapping[computedHashedPhrase] }("");
            if(!success)
                revert();
        }
        else 
            revert();
    }

    function getHash(
        string memory str
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(str));
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    //sign - passPhrase, msg.sender
    function withdrawEth(
        string memory _passPhrase
    ) external {
        bytes32 computedHashedPhrase = keccak256(abi.encodePacked(_passPhrase));
        if(amountMapping[computedHashedPhrase] > 0) {
            amountMapping[computedHashedPhrase] = 0;
            (bool success, ) = msg.sender.call{ value: amountMapping[computedHashedPhrase] }("");
            if(!success)
                revert();
        }
        else 
            revert();
    }
}
