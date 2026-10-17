// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Script, console} from "forge-std/Script.sol";
import {DeploymentScirptBase} from "./DeploymentScirptBase.sol";

contract FccUsdtERC20 is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply, address owner) ERC20(name, symbol) {
        _mint(owner, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}

contract IERC20Deployer is DeploymentScirptBase {
    address public constant DEPLOYER_ADDRESS = 0x5CFbfE556626350D7105e2dFe96F4cf03056f754;
    uint256 public constant USDT_INITIAL_SUPPLY = 1_000_000 * 10 ** 6; // 1 million USDT with 6 decimals

    function run() public returns (address token) {
        return deploy(DEPLOYER_ADDRESS, USDT_INITIAL_SUPPLY);
    }

    function deploy(address deployer, uint256 initialSupply) public returns (address token){
        require(initialSupply > 0, "USDT:supply is zero");
        _startDeployment(deployer);
        token = address(new FccUsdtERC20("Amoy Test USDT", "aUSDT", initialSupply, deployer));
        vm.stopBroadcast();
        console.log("USDT_ADDRESS:", token);
        console.log("Initial Supply(6 decimals):", initialSupply);
        console.log("Initial holder:", deployer);
    }
}
