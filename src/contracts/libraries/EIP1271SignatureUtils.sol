// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.8.12;

import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


library EIP1271SignatureUtils {
    bytes4 internal constant EIP1271_MAGICVALUE = 0x1626ba7e;

    function checkSignature_EIP1271(address signer, bytes32 digestHash, bytes memory signature) internal view {
        if (Address.isContract(signer)) {
            require(
                IERC1271(signer).isValidSignature(digestHash, signature) == EIP1271_MAGICVALUE,
                "EIP1271SignatureUtils.checkSignature_EIP1271: ERC1271 signature verification failed"
            );
        } else {
            require(
                ECDSA.recover(digestHash, signature) == signer,
                "EIP1271SignatureUtils.checkSignature_EIP1271: signature not from signer"
            );
        }
    }
}