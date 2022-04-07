// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";

contract Tokenomics is Ownable {
    uint public constant timeLock =  3 * 365 days;
    uint public start = block.timestamp;
    string[] public initMinters = ['initBurn', 'farm', 'stakeBox', 'ecoPartner', 'airdrop', 'pancakeList', '1stCex', '2ndCex', '3rdCex', 'binanceList'];
    string[] public initLockers = ['futureInvester', 'team', 'marketing'];
    uint[] public initMintersPercent = [100, 60, 100, 40, 10, 100, 100, 100, 140, 50];
    uint[] public initLockersPercent = [60, 70, 70];
    mapping(string => address) public minterAddress;
    mapping(string => address) public lockerAddress;
    mapping(address => uint) public minterAmount;
    mapping(address => uint) public lockerAmount;
    mapping(address => bool) public isMinterWithdraw;
    bool public isInit;

    event Init (IBEP20 _erc20, uint _amount);
    event Unlock(IBEP20 _erc20, address _locker);
    event Withdraw(address _minter, uint _amount);

    constructor() {
        minterAddress['initBurn'] = 0x88723F606b78A2d98dD51d2AE197cd408D850444;
        minterAddress['farm'] = 0x14CAA5833b4F4d7adfA0b9bcdfD79807d5ee47a2;
        minterAddress['stakeBox'] = 0x8e56574ce6415c8AbAde8470649cdE6003884843;
        minterAddress['ecoPartner'] = 0x7b16ae811f7fb886C650154A4C08694D502D9954;
        minterAddress['airdrop'] = 0xBbDc15d3400CE9CBF4E0683aE72f87EE083Cc900;
        minterAddress['pancakeList'] = 0x1939F114f3D6775d3269125a39d9996C053E3aF7;
        minterAddress['1stCex'] = 0x03EFc9007bD5360d63623e6fdd3b9865842C27ad;
        minterAddress['2ndCex'] = 0x0da6b3f46b2fb3755E3a639898fF333635E5a046;
        minterAddress['3rdCex'] = 0xbE118f252F7c584d894d969E7062E1d986B3090a;
        minterAddress['binanceList'] = 0x8E3d703588707eb77cf6aE4f8959A0B560A4Aed8;

        lockerAddress['futureInvester'] = 0x43a77A02D23BEc1Fdc95CfE4E7E7729a1a44a497;
        lockerAddress['team'] = 0xeEbe5416F98eb7c611740dB492B606913990947e;
        lockerAddress['marketing'] = 0x0e0c3240dd07667Ae80E69B77CaCD6Db928B75A5;
    }
    function init(IBEP20 _erc20, uint _amount) external {
        require(!isInit, 'Tokenomics: already init');
        require(_erc20.allowance(_msgSender(), address(this)) >= _amount, 'Tokenomics: Allow erc20 first');
        require(_erc20.transferFrom(_msgSender(), address(this), _amount));
        for(uint i = 0; i < initMintersPercent.length; i++){
            uint _total = _amount * initMintersPercent[i] / 1000;
            minterAmount[minterAddress[initMinters[i]]] = _total;
        }
        for(uint i = 0; i < initLockersPercent.length; i++){
            uint _total = _amount * initLockersPercent[i] / 1000;
            lockerAmount[lockerAddress[initLockers[i]]] = _total;
        }
        isInit = true;
        emit Init(_erc20, _amount);
    }
    function withdraw(IBEP20 _erc20, string memory _role) external {
        require(_msgSender() == minterAddress[_role], 'Tokenomics: cant access');
        require(minterAmount[minterAddress[_role]] > 0, 'Tokenomics: no balance');
        _erc20.transfer(minterAddress[_role], minterAmount[minterAddress[_role]]);
        emit Withdraw(_msgSender(), minterAmount[minterAddress[_role]]);
        minterAmount[minterAddress[_role]] = 0;
    }
    function unlock(IBEP20 _erc20, string memory _role) external {
        require(block.timestamp - start >= timeLock, 'Tokenomics: no meet lock time');
        require(_msgSender() == lockerAddress[_role], 'Tokenomics: cant access');
        require(lockerAmount[lockerAddress[_role]] > 0, 'Tokenomics: no balance');
        require(_erc20.transfer(_msgSender(), lockerAmount[_msgSender()]));
        lockerAmount[lockerAddress[_role]] = 0;
        emit Unlock(_erc20, _msgSender());
    }
    function getInitLockers() external view returns(string[] memory){
        return initLockers;
    }
    function getInitLockersPercent() external view returns(uint[] memory){
        return initLockersPercent;
    }
    function getInitMinters() external view returns(string[] memory){
        return initMinters;
    }
    function getInitMintersPercent() external view returns(uint[] memory){
        return initMintersPercent;
    }
}