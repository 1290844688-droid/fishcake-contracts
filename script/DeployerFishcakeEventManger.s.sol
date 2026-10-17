// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/contracts/core/FishcakeEventManagerV2.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "forge-std/Script.sol";
import {DeploymentScirptBase} from "./DeploymentScirptBase.sol";
import {Script, console} from "forge-std/Script.sol";

contract DeployerFishcakeEventMangerScript is DeploymentScirptBase {
    address public constant DEPLOYER_ADDRESS = 0x5CFbfE556626350D7105e2dFe96F4cf03056f754;

    address public constant USDT_ADDRESS = 0xb35E1cfbdAC1949cDe6FD8e24c1DA0ffBE469cB3;

    function run() public returns (address proxy){
        require(DEPLOYER_ADDRESS != address(0), "EventManager: deployer is zero");
        return deployActivityOnly(DEPLOYER_ADDRESS, USDT_ADDRESS);
    }


    function deployActivityOnly(address deployer, address usdtAddress) public returns (address proxy) {
        _requireToken(usdtAddress, "USDT");
        proxy = _deployInitialized(deployer, address(0), usdtAddress, address(0));
        console.log("ActivityAdd-only test instrance:FCC and NFT are unset");
        console.log("Do not use reward,finish or refund paths with this instance");
    }

    function _deployInitialized(address deployer, address fccAddress, address usdtAddress, address nftAddress)
    private returns (address proxy) {
        _startDeployment(deployer);
        address implementation = address(new FishcakeEventManagerV2());
        proxy = _deployTransparent(
            implementation,
            deployer,
            abi.encodeCall(FishcakeEventManagerV2.initialize, (deployer, fccAddress, usdtAddress, nftAddress))
        );
        vm.stopBroadcast();
        console.log("EVENT_MANAGER_ADDRESS:", proxy);
        _logTransparent(implementation, proxy);
    }
}
