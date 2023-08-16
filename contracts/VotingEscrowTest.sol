pragma solidity 0.8.19;
import "./VotingEscrow.sol";
import "./helper.sol";
import "./IVM.sol";

contract medusaTesting is PropertiesAsserts {
    uint256 public constant WEEK = 7 days;

    VotingEscrow votingEscrow = new VotingEscrow("Voting Escrow", "VE");


    function _floorToWeek(uint256 _t) internal pure returns (uint256) {
        return (_t / WEEK) * WEEK;
    }

    function test_createLock(uint256 x) public {
        votingEscrow.createLock{value: x}(x);
        
        (, , , address delegatee) = votingEscrow.locked(msg.sender);
        // assert(delegatee == msg.sender);
        assertEq(votingEscrow.lockEnd(msg.sender), _floorToWeek(block.timestamp + votingEscrow.LOCKTIME()), "lockEnd must match");
    }

}