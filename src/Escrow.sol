// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Escrow {
    address public buyer;
    address payable public seller;
    address public inspector;
    address public lender;

    enum State {
        AWAITING_PAYMENT,
        AWATING_INSPECTION,
        AWATING_APPROVAL,
        COMPLETE
    }

    State public currentState;

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function");
        _;
    }

    modifier onlyInspector() {
        require(msg.sender == inspector, "Only inspector can call this function");
        _;
    }

    modifier inState(State expectedState) {
        require(currentState == expectedState, "Invalid state");
        _;
    }

    constructor(address _buyer, address payable _seller, address _inspector, address _lender) {
        buyer = _buyer;
        seller = _seller;
        inspector = _inspector;
        lender = _lender;
        currentState = State.AWAITING_PAYMENT;
    }

    function deposit() external payable onlyBuyer inState(State.AWAITING_PAYMENT) {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        currentState = State.AWATING_INSPECTION;
    }

    function confirmInspection(bool approved) external onlyInspector inState(State.AWATING_INSPECTION) {
        currentState = approved ? State.AWATING_APPROVAL : State.AWAITING_PAYMENT;
    }

    function approveSale() external onlyBuyer inState(State.AWATING_APPROVAL) {
        currentState = State.COMPLETE;
        seller.transfer(address(this).balance);
    }

    function cancelSale() external onlyBuyer inState(State.AWATING_APPROVAL) {
        currentState = State.AWAITING_PAYMENT;
        payable(buyer).transfer(address(this).balance);
    }
}