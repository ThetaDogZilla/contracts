// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IDogStaking.sol";

//import "hardhat/console.sol";

contract DogStaking is IDogStaking, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20  public immutable token;
    
    uint256 public startPeriod;
    uint256 public duration   ;

    mapping(address => Staker ) public  staker         ;
    mapping(uint256 => address) public  stakerId       ;
    uint256                     private numberOfStakers;

    uint256 public   totalReward  ;
    uint256 public   leftReward   ;
    uint256 public   totalStaked  ;
    uint256 public   totalToClaim ;
    uint256 public   totalClaimed ;
    uint256 public   variableAPY  ;
    uint256 public   decimals     ;
    uint256 public   unstakePeriod;
    bool    public   paused       ;

    struct Staker {
        uint256 stakedAmount  ;
        uint256 rewardsToClaim;
        uint256 rewardsClaimed;
        uint256 timestamp     ;
        bool    unstaking     ;
        uint256 unstakeTime   ;
        uint256 unstakeAmount ;
        uint256 initStakeTime ; 
    }

    /**
     * @notice constructor contains all the parameters of the staking platform
     * @dev all parameters are immutable
     */
    constructor(
        address _token        ,
        uint256 _start        ,
        uint256 _duration     ,
        uint256 _unstakePeriod
    ) {
        token           = IERC20(_token);
        totalReward     = 0             ;
        leftReward      = 0             ;
        totalStaked     = 0             ;
        totalClaimed    = 0             ;
        startPeriod     = _start        ;
        duration        = _duration     ;
        decimals        = 1000000       ;
        unstakePeriod   = _unstakePeriod;
        paused          = false         ;
    }

    /* ===================================================================================
       ================================== DEV FUNCTIONS ==================================
       ===================================================================================
    */
    /**
     * @dev Reward token deposit
     * @param amount to deposit
     */
    function devDeposit(uint256 amount) external onlyOwner {
        require(amount>0, "Amount must be higher than 0");
        token.safeTransferFrom(msg.sender, address(this), amount); 
        totalReward += amount;
        leftReward   = totalReward - totalClaimed;
    }

    /**
     * @dev Reward token withdrawal
     * @param amount to withdrawal
     */
    function devWithdrawal(uint256 amount) external onlyOwner {
        require(amount<=leftReward, "Amount must be less than leftReward");
        token.safeTransfer(msg.sender, amount); 
        totalReward -= amount;

        leftReward   = totalReward - totalClaimed;
    }

    /**
     * @dev Pause rewards
     * @param pause boolean
     */
    function devPause(bool pause) external onlyOwner {
        // Compute rewards
        _computeAllRewards(); 
        // Paused
        paused = pause;
    }

    /**
     * @dev Change unstake period
     * @param period unstake period
     */
    function devUnstakePeriod(uint256 period) external onlyOwner {
        unstakePeriod = period;
    }

    /* ===================================================================================
       ================================ USER FUNCTIONS ===================================
       ===================================================================================
    */
    /**
     * @dev Stake
     * @param amount amount to stake
     */
    function stake(uint256 amount) external override nonReentrant {
        require(amount>0, "Amount must be higher than 0");
        require(staker[msg.sender].unstaking == false, "Not possible to stake");
        require(startPeriod<=block.timestamp);

        // Loyal holder check
        if (staker[msg.sender].stakedAmount == 0) 
            staker[msg.sender].initStakeTime = block.timestamp;

        token.safeTransferFrom(msg.sender, address(this), amount); 

        // Compute rewards
        _computeAllRewards();    

        // Increase staked amount
        staker[msg.sender].stakedAmount += amount;
        totalStaked                     += amount;

        // If its a new staker, add it to the list
        bool newStaker = _isNewStaker(msg.sender);
        if (newStaker == true) {
            // Add new staker ID
            stakerId[numberOfStakers] = msg.sender;
            numberOfStakers += 1;
            // First timestamp
            staker[msg.sender].timestamp = block.timestamp;
        } 
                    
        // Recalculate APY
        _calculateAPY();

        emit Staked(msg.sender,amount, staker[msg.sender].stakedAmount);
    }

    /**
     * @dev Unstake tokens
     */
    function unstake() external override nonReentrant {
        require(staker[msg.sender].stakedAmount>0, "Amount must be higher than 0");

        // Unstaking
        staker[msg.sender].unstaking = true;

        // Time when unstake begins
        staker[msg.sender].unstakeTime = block.timestamp;

        // Unstaking amount 
        staker[msg.sender].unstakeAmount = staker[msg.sender].stakedAmount;

        // Compute rewards
        _computeAllRewards();      

        // Decrease staked amount
        totalStaked                     -= staker[msg.sender].stakedAmount;
        staker[msg.sender].stakedAmount  = 0;

        // Not loyal holder
        staker[msg.sender].initStakeTime = 0;

        // Recalculate APY
        _calculateAPY();
    }

    /**
     * @dev Withdrawal tokens
     */
    function withdrawal() external override nonReentrant {
        uint256 amount = staker[msg.sender].unstakeAmount;
        uint256 unstakeDuration = block.timestamp - staker[msg.sender].unstakeTime;
        require(unstakeDuration >= unstakePeriod, "Unstake period not reached");
        require(staker[msg.sender].unstaking == true, "Not possible to unstake");

        // Unstaked
        staker[msg.sender].unstaking = false;

        // Withdrawal
        token.safeTransfer(msg.sender, staker[msg.sender].unstakeAmount); 

        // Unstaking amount 
        staker[msg.sender].unstakeAmount = 0;

        emit Unstaked(msg.sender, amount);
    }

    /**
     * @dev Claim rewards
     */
    function claim() external override nonReentrant {
        require(!_isNewStaker(msg.sender), "It's not a staker");

        // Compute rewards
        _computeAllRewards();
        require(staker[msg.sender].rewardsToClaim >=0, "No rewards to claim");

        // Transfer to staker
        token.safeTransfer(msg.sender, staker[msg.sender].rewardsToClaim);

        // Rewards to claim back to 0
        totalClaimed += staker[msg.sender].rewardsToClaim;
        totalToClaim -= staker[msg.sender].rewardsToClaim;
        staker[msg.sender].rewardsClaimed += staker[msg.sender].rewardsToClaim;
        leftReward    = totalReward - totalClaimed;

        staker[msg.sender].rewardsToClaim = 0;
    }

    /**
     * @dev Get locked period
     * @param stakerAddr staker address
     * @return locked period
     */
    function getLockedPeriod(address stakerAddr) external override view returns (uint256) {
        if (staker[stakerAddr].unstaking)
            return staker[stakerAddr].unstakeTime + unstakePeriod;
        else
            return 0;
    }

    /**
     * @dev Get is locked
     * @param stakerAddr staker address
     * @return if its locked
     */
    function getIsLocked(address stakerAddr) external override view returns (bool) {
        return staker[stakerAddr].unstaking;
    }

    /**
     * @dev Get unstake amount
     * @param stakerAddr staker address
     * @return unstake amount
     */
    function getUnstakeAmount(address stakerAddr) external override view returns (uint256) {
        if (staker[stakerAddr].unstaking)
            return staker[stakerAddr].unstakeAmount;
        else
            return 0;
    }

    /**
     * @dev Get all staked addresses
     * @return address[] adresses
     * @return uint256[] amounts
     */
    function getAllStakedAddresses() external override view returns (address[] memory, uint256[] memory) {
        uint256 stakerNum = 0;
        for (uint256 i = 0; i < numberOfStakers; i++) {
            if (staker[stakerId[i]].stakedAmount > 0)
                stakerNum++;
        }

        address [] memory stakers = new address [](stakerNum);
        uint256 [] memory amount  = new uint256 [](stakerNum);

        uint256 counter;
        for (uint256 i = 0; i < numberOfStakers; i++) {
            if (staker[stakerId[i]].stakedAmount > 0) {
                stakers[counter] = stakerId[i];
                amount [counter] = staker[stakerId[i]].stakedAmount;

                counter++;
            }
        }
        return (stakers, amount);
    }

    /**
     * @dev Get all unstaking addresses
     * @return address[] adresses
     * @return uint256[] amounts
     */
    function getAllUnstakingAddresses() external override view returns (address[] memory, uint256[] memory, uint256[] memory) {
        uint256 stakerNum = 0;
        for (uint256 i = 0; i < numberOfStakers; i++) {
            if (staker[stakerId[i]].unstaking == true)
                stakerNum++;
        }

        address [] memory stakers = new address [](stakerNum);
        uint256 [] memory amount  = new uint256 [](stakerNum);
        uint256 [] memory locktime= new uint256 [](stakerNum);

        uint256 counter;
        for (uint256 i = 0; i < numberOfStakers; i++) {
            if (staker[stakerId[i]].unstaking == true) {
                stakers[counter]  = stakerId[i];
                amount [counter]  = staker[stakerId[i]].unstakeAmount;
                locktime[counter] = staker[stakerId[i]].unstakeTime;

                counter++;
            }
        }
        return (stakers, amount, locktime);
    }

    /**
     * @dev Get loyal holders
     * @return address[] adresses
     * @return uint256[] timestamp
     */
    function getLoyalHolder() external override view returns (address[] memory, uint256[] memory) {
        uint256 stakerNum = 0;
        for (uint256 i = 0; i < numberOfStakers; i++) {
            if (staker[stakerId[i]].initStakeTime > 0)
                stakerNum++;
        }

        address [] memory stakers = new address [](stakerNum);
        uint256 [] memory amount  = new uint256 [](stakerNum);

        uint256 counter;
        for (uint256 i = 0; i < numberOfStakers; i++) {
            if (staker[stakerId[i]].initStakeTime > 0) {
                stakers [counter] = stakerId[i];
                amount  [counter] = staker[stakerId[i]].initStakeTime;
                counter++;
            }
        }
        return (stakers, amount);
    }

    /**
     * @dev Get unstake amount
     * @param stakerAddr staker address
     * @return stake init time
     */
    function getInitStakeTime(address stakerAddr) external override view returns (uint256) {
        return staker[stakerAddr].initStakeTime;
    }

    /**
     * @dev Get timestamp
     * @param stakerAddr staker address
     * @return timestamp
     */
    function getTimestamp(address stakerAddr) external override view returns (uint256) {
        return staker[stakerAddr].timestamp;
    }

    /**
     * @dev Get APY
     * @return APY
     */
    function getAPY() external override view returns (uint256) {
        return variableAPY * (60*60*24*365) / duration;
    }

    /**
     * @dev Compute rewards
     * @param stakerAddr staker address
     * @return rewards for a staker
     */
    function computeRewards(address stakerAddr) external override returns (uint256) {

        return _computeRewards(stakerAddr);
    }

    /**
     * @dev Compute all rewards
     */
    function computeAllRewards() external override {

        return _computeAllRewards();
    }

    /**
     * @dev Staked amount
     * @param stakerAddr staker address
     * @return staked amount
     */
    function getStakedAmount(address stakerAddr) external override view returns (uint256) {
        return staker[stakerAddr].stakedAmount;
    }

    /**
     * @dev Unclaimed rewards
     * @param stakerAddr staker address
     * @return staked amount
     */
    function getUnclaimedRewards(address stakerAddr) external override view returns (uint256) {
        
        return (staker[stakerAddr].rewardsToClaim + _getUnclaimedRewards(stakerAddr));
    }

    /**
     * @dev Get DOGZ per hour
     * @param stakerAddr staker address
     * @return DOGZ per hour
     */
    function getDOGZPerHour(address stakerAddr) external override view returns (uint256) {
        uint256 oneHourInSeconds = 3600;

        uint256 rewards = staker[stakerAddr].stakedAmount * oneHourInSeconds * variableAPY / (decimals * duration);

        return rewards;
    }
    

    /* ===================================================================================
       ============================== INTERNAL FUNCTIONS =================================
       ===================================================================================
    */
    /**
     * @dev Function "isNewStaker"
     * @param stakerAddr staker address
     * @return if a given address is staker
     */
    function _isNewStaker(address stakerAddr) internal view returns (bool) {
        // If no stakers, return true
        if(numberOfStakers==0)
            return true;

        // If there are stakers, loop
        for (uint256 i = 0; i < numberOfStakers; i++) {
            if(stakerId[i] == stakerAddr)
                return false;
        }
        return true;
    }

    /**
     * @dev Compute all rewards
     */
    function _computeAllRewards() internal {
        for (uint256 i = 0; i < numberOfStakers; i++) {
            // Compute rewards
            _computeRewards(stakerId[i]);            
        }
    }

    /**
     * @dev Compute rewards
     * @param stakerAddr staker address
     * @return rewards for a staker
     */
    function _computeRewards(address stakerAddr) internal returns (uint256){
        // Calculate rewards
        uint256 rewards = _getUnclaimedRewards(stakerAddr);

        // Add rewards to claim
        staker[stakerAddr].rewardsToClaim += rewards;
        totalToClaim                      += rewards;

        // Update timestamp
        staker[stakerAddr].timestamp = block.timestamp;   

        return rewards;
    }

    /**
     * @dev Unclaimed rewards
     * @param stakerAddr staker address
     * @return staked amount
     */
    function _getUnclaimedRewards(address stakerAddr) internal view returns (uint256) {

        // Calculate stake duration
        uint256 durationInSeconds = block.timestamp - staker[stakerAddr].timestamp;
        uint256 rewards;

        // If staking period elapsed
        if(block.timestamp > (startPeriod + duration)) {
            // Second time entered
            if(staker[stakerAddr].timestamp > (startPeriod + duration)) {
                durationInSeconds = 0;
            } 
            // First time entered
            else {
                durationInSeconds = startPeriod + duration - staker[stakerAddr].timestamp;
            }
        }

        // If its paused
        if(paused) {
            durationInSeconds = 0;
        }

        rewards = staker[stakerAddr].stakedAmount * durationInSeconds * variableAPY / (decimals * duration);
        
        return rewards;
    }

    /**
     * @dev Calculate APY
     */
    function _calculateAPY() internal {
        if (totalStaked > 0)
            variableAPY = decimals*totalReward/totalStaked;
        else 
            variableAPY = 0;

        emit NewAPY(variableAPY);
    }

}