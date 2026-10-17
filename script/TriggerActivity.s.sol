// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {DeploymentScirptBase} from "./DeploymentScirptBase.sol";
import {FishcakeEventManagerV2}  from  "../src/contracts/core/FishcakeEventManagerV2.sol";

contract TriggerActivityScript is DeploymentScirptBase {

    using SafeERC20 for IERC20;

    address public constant ACTOR_ADDRESS = 0x5CFbfE556626350D7105e2dFe96F4cf03056f754;
    address public constant EVENT_MANAGER_ADDRESS = 0x56c2115c021E89a97211da39A83727332Fb9d4C4;
    string  public constant BUSINESS_NAME = "Amoy Test Business";
    string  public constant ACTIVITY_CONTENT = "ActivityAdd intergration test";
    string  public constant LATITUDE_LONGTITUDE = "100,50";
    uint256 public constant ACTIVITY_DURATION = 1 days;
    uint256 public constant DROP_COUNT = 10;
    uint256 public constant AMOUNT_PRE_DROP = 1 * 10 * 6;
    uint256 public constant TOTAL_DROP_AMOUNT = DROP_COUNT * AMOUNT_PRE_DROP;

    function run() public {
        require(ACTOR_ADDRESS != address(0), "Activity: actor is zero");
        return trigger(ACTOR_ADDRESS, EVENT_MANAGER_ADDRESS);
    }

    function trigger(address actor, address eventAddress) public returns (uint256 activityId) {
        require(actor != address(0), "Activity: actor is zero");
        _requireCode(eventAddress, "Event manager");
        FishcakeEventManagerV2 eventManager = FishcakeEventManagerV2(eventAddress);
        address tokenAddress = address(eventManager.UsdtTokenAddr());
        _requireToken(tokenAddress, "Activity USDT");
        require(ACTIVITY_DURATION > 0 && ACTIVITY_DURATION < eventManager.maxDeadLine(), "Activity: invalid duration");
        require(DROP_COUNT > 0 && DROP_COUNT <= 100, "Activity: drop count must be 1..100");
        require(TOTAL_DROP_AMOUNT >= 1 * 10 ** 6, "Activity: total must be at least 1 USDT");
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(actor) >= TOTAL_DROP_AMOUNT, "Activity: insufficient USDT balance");
        uint256 deadline = block.timestamp + ACTIVITY_DURATION;
        _startDeployment(actor);
        token.forceApprove(eventAddress, TOTAL_DROP_AMOUNT);
        bool success;
        (success, activityId) = eventManager.activityAdd(
            BUSINESS_NAME,
            ACTIVITY_CONTENT,
            LATITUDE_LONGTITUDE,
            deadline,
            TOTAL_DROP_AMOUNT,
            1,
            DROP_COUNT,
            0,
            AMOUNT_PRE_DROP,
            tokenAddress
        );
        require(success, "Activity creation failed");
        vm.stopBroadcast();
        console.log("Activity proxy (event emitter) ", eventAddress);
        console.log("Activity creator ", actor);
        console.log("Activity ID ", activityId);
        console.log("USDT token ", tokenAddress);
        console.log("Locked USDT (6 decimals) ", TOTAL_DROP_AMOUNT);
        console.log("Activity deadline ", deadline);
    }
}