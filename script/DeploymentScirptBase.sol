// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

abstract contract DeploymentScirptBase is Script {

    function _startDeployment(address deployer) internal {
        require(block.chainid == 80002, "Deployment: chain must be Amoy (80002)");
        require(deployer != address(0), "Deployment: deployer is zero");
        vm.startBroadcast(deployer);
    }

    function _requireCode(address target, string memory lable) internal view {
        require(target.code.length > 0, string.concat(lable, ": address has no code"));
    }

    function _requireToken(address token, string memory label) internal view {
        _requireCode(token,label);
        require(IERC20Metadata(token).decimals() == 6, string.concat(label, ": token decimals is not 6"));
    }

    function _deployTransparent(address implementation, address owner, bytes  memory data) internal
    returns (address proxy){
        proxy = address(new TransparentUpgradeableProxy(implementation, owner, data));
    }

    function _logTransparent(address implementation, address proxy) internal view {
        address admin = address(uint160(uint256(vm.load(proxy, ERC1967Utils.ADMIN_SLOT))));
        console.log("Implementation address:", implementation);
        console.log("Proxy (business address)", proxy);
        console.log("ProxyAdmin", admin);
    }
}
