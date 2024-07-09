// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";

contract BuyerMock {
    receive() external payable {}
}

contract EscrowTest is Test {
    Escrow public escrow;
    BuyerMock public buyerMock;
    address public buyer;
    address payable public seller;
    address public inspector;
    address public lender;

    function setUp() public {
        buyerMock = new BuyerMock();
        buyer = address(buyerMock);
        seller = payable(address(2));
        inspector = address(3);
        lender = address(4);

        escrow = new Escrow(buyer, seller, inspector, lender);
    }

    function testInitialState() public {
        assertEq(escrow.buyer(), buyer);
        assertEq(escrow.seller(), seller);
        assertEq(escrow.inspector(), inspector);
        assertEq(escrow.lender(), lender);
        assertEq(uint(escrow.currentState()), uint(Escrow.State.AWAITING_PAYMENT));
    }

    function testDeposit() public {
        vm.prank(buyer);
        vm.deal(buyer, 1 ether);
        escrow.deposit{value: 1 ether}();

        assertEq(uint(escrow.currentState()), uint(Escrow.State.AWATING_INSPECTION));
        assertEq(address(escrow).balance, 1 ether);
    }

    function testDepositFailsWithZeroAmount() public {
        vm.prank(buyer);
        vm.expectRevert("Deposit amount must be greater than zero");
        escrow.deposit{value: 0}();
    }

    function testDepositFailsFromNonBuyer() public {
        vm.deal(seller, 1 ether);
        vm.prank(seller);
        vm.expectRevert("Only buyer can call this function");
        escrow.deposit{value: 1 ether}();
    }

    function testConfirmInspection() public {
        vm.prank(buyer);
        vm.deal(buyer, 1 ether);
        escrow.deposit{value: 1 ether}();

        vm.prank(inspector);
        escrow.confirmInspection(true);

        assertEq(uint(escrow.currentState()), uint(Escrow.State.AWATING_APPROVAL));
    }

    function testConfirmInspectionFail() public {
        vm.prank(buyer);
        vm.deal(buyer, 1 ether);
        escrow.deposit{value: 1 ether}();

        vm.prank(inspector);
        escrow.confirmInspection(false);

        assertEq(uint(escrow.currentState()), uint(Escrow.State.AWAITING_PAYMENT));
    }

    function testApproveSale() public {
        vm.prank(buyer);
        vm.deal(buyer, 1 ether);
        escrow.deposit{value: 1 ether}();

        vm.prank(inspector);
        escrow.confirmInspection(true);

        uint256 initialSellerBalance = seller.balance;

        vm.prank(buyer);
        escrow.approveSale();

        assertEq(uint(escrow.currentState()), uint(Escrow.State.COMPLETE));
        assertEq(seller.balance, initialSellerBalance + 1 ether);
        assertEq(address(escrow).balance, 0);
    }

    function testCancelSale() public {
        vm.prank(buyer);
        vm.deal(buyer, 1 ether);
        escrow.deposit{value: 1 ether}();

        vm.prank(inspector);
        escrow.confirmInspection(true);

        uint256 initialBuyerBalance = buyer.balance;

        vm.prank(buyer);
        escrow.cancelSale();

        assertEq(uint(escrow.currentState()), uint(Escrow.State.AWAITING_PAYMENT));
        assertEq(buyer.balance, initialBuyerBalance + 1 ether);
        assertEq(address(escrow).balance, 0);
    }

    function testInvalidStateTransitions() public {
        // Try to approve sale before inspection
        vm.prank(buyer);
        vm.expectRevert("Invalid state");
        escrow.approveSale();

        // Try to cancel sale before inspection
        vm.prank(buyer);
        vm.expectRevert("Invalid state");
        escrow.cancelSale();

        // Try to confirm inspection before deposit
        vm.prank(inspector);
        vm.expectRevert("Invalid state");
        escrow.confirmInspection(true);
    }
}