// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Escrow} from "../src/Escrow.sol";

contract DeployEscrow is Script {
    address buyer;
    address payable seller;
    address inspector;
    address lender;
    Escrow escrow;

    function run() external returns (Escrow) {
        buyer = 0x1234567890123456789012345678901234567890;
        seller = payable(0x0987654321098765432109876543210987654321);
        inspector = 0x5555555555555555555555555555555555555555;
        lender = 0x6666666666666666666666666666666666666666;

        vm.startBroadcast();
        escrow = new Escrow(buyer, seller, inspector, lender);
        console.log("Contract is deployed to address: ", address(escrow));
        vm.stopBroadcast();
        return escrow;
    }
}