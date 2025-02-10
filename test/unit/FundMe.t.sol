// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 private constant STARTING_BALANCE = 10 ether; // Same as 10e18
    uint256 private constant SEND_VALUE = 0.1 ether; // Same as 1e17
    address USER = makeAddr("user");
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testMinimumUSDisFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerisRealOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
        console.log("This is the deployed fundMe address", address(fundMe));
        console.log("This is the FundMeTest address", address(this));
        console.log("This is Me", msg.sender);
        console.log(
            "This is the deployed fundMe OWNER address",
            fundMe.getOwner()
        );
    }

    function testPricefeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        if (block.chainid == 1) {
            assertEq(version, 6);
        } else if (block.chainid == 11155111) {
            assertEq(version, 4);
        } else {
            assertEq(version, 4);
        }
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdateFundDatastructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testAddFundersToTheArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingBalanceOfOwner = fundMe.getOwner().balance;
        uint256 startingBalanceOfFundMe = address(fundMe).balance;

        // Action
        address owner = fundMe.getOwner();
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        uint256 endingBalanceOfOwner = fundMe.getOwner().balance;
        uint256 endingBalanceOfFundMe = address(fundMe).balance;
        assertEq(endingBalanceOfFundMe, 0);
        assertEq(
            startingBalanceOfOwner + startingBalanceOfFundMe,
            endingBalanceOfOwner
        );
    }

    function testWithdrawFromMultipleFunderscheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (
            uint160 i = startingFunderIndex;
            i < numberOfFunders + startingFunderIndex;
            i++
        ) {
            // hoax keyword = (deal and prank) at the same  time
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingBalanceOfOwner = fundMe.getOwner().balance;
        uint256 startingBalanceOfFundMe = address(fundMe).balance;

        // Action
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        // Assert
        uint256 endingBalanceOfOwner = fundMe.getOwner().balance;
        uint256 endingBalanceOfFundMe = address(fundMe).balance;
        assertEq(endingBalanceOfFundMe, 0);
        assertEq(
            startingBalanceOfOwner + startingBalanceOfFundMe,
            endingBalanceOfOwner
        );
        assert(
            (numberOfFunders + 1) * SEND_VALUE ==
                endingBalanceOfOwner - startingBalanceOfOwner
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (
            uint160 i = startingFunderIndex;
            i < numberOfFunders + startingFunderIndex;
            i++
        ) {
            // hoax keyword = (deal and prank) at the same  time
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingBalanceOfOwner = fundMe.getOwner().balance;
        uint256 startingBalanceOfFundMe = address(fundMe).balance;

        // Action
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingBalanceOfOwner = fundMe.getOwner().balance;
        uint256 endingBalanceOfFundMe = address(fundMe).balance;
        assertEq(endingBalanceOfFundMe, 0);
        assertEq(
            startingBalanceOfOwner + startingBalanceOfFundMe,
            endingBalanceOfOwner
        );
        assert(
            (numberOfFunders + 1) * SEND_VALUE ==
                endingBalanceOfOwner - startingBalanceOfOwner
        );
    }

    function testPrintStorageData() public view {
        for (uint256 i = 0; i < 3; i++) {
            bytes32 value = vm.load(address(fundMe), bytes32(i));
            console.log("value at location", i, ":");
            console.logBytes32(value);
        }
        console.log("Pricefeed address", address(fundMe.getPriceFeed()));
        console.log("This cntract's address :", address(fundMe));
    }
}
