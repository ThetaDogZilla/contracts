// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDogStaking {
  /* ===================================================================================
     ================================ USER FUNCTIONS ===================================
     ===================================================================================
  */
  /**
    * @dev Stake
    * @param amount amount to stake
    */
  function stake(uint256 amount) external;

  /**
    * @dev Unstake tokens
    */
  function unstake() external;

  /**
    * @dev Withdrawal tokens
    */
  function withdrawal() external;

  /**
    * @dev Claim rewards
    */
  function claim() external;

  /**
    * @dev Get locked period
    * @param stakerAddr staker address
    * @return locked period
    */
  function getLockedPeriod(address stakerAddr) external view returns (uint256);

  /**
    * @dev Get is locked
    * @param stakerAddr staker address
    * @return if its locked
    */
  function getIsLocked(address stakerAddr) external view returns (bool);

  /**
    * @dev Get unstake amount
    * @param stakerAddr staker address
    * @return unstake amount
    */
  function getUnstakeAmount(address stakerAddr) external view returns (uint256);

  /**
    * @dev Get all staked addresses
    * @return address[] adresses
    * @return uint256[] amounts
    */
  function getAllStakedAddresses() external view returns (address[] memory, uint256[] memory);
  
  /**
    * @dev Get all unstaking addresses
    * @return address[] adresses
    * @return uint256[] amounts
    */
  function getAllUnstakingAddresses() external view returns (address[] memory, uint256[] memory, uint256[] memory);

  /**
    * @dev Get APY
    * @return APY
    */
  function getAPY() external view returns (uint256);

  /**
    * @dev Compute rewards
    * @param stakerAddr staker address
    * @return rewards for a staker
    */
  function computeRewards(address stakerAddr) external returns (uint256);

  /**
    * @dev Compute all rewards
    */
  function computeAllRewards() external;

  /**
    * @dev Staked amount
    * @param stakerAddr staker address
    * @return staked amount
    */
  function getStakedAmount(address stakerAddr) external view returns (uint256);

  /**
    * @dev Unclaimed rewards
    * @param stakerAddr staker address
    * @return staked amount
    */
  function getUnclaimedRewards(address stakerAddr) external view returns (uint256);

  /**
    * @dev Get DOGZ per hour
    * @param stakerAddr staker address
    * @return DOGZ per hour
    */
  function getDOGZPerHour(address stakerAddr) external view returns (uint256);

  /**
    * @dev Get loyal holders
    * @return address[] adresses
    * @return uint256[] timestamp
    */
  function getLoyalHolder() external view returns (address[] memory, uint256[] memory);

  /**
    * @dev Get unstake amount
    * @param stakerAddr staker address
    * @return unstake amount
    */
  function getInitStakeTime(address stakerAddr) external view returns (uint256);

  /**
    * @dev Get timestamp
    * @param stakerAddr staker address
    * @return timestamp
    */
  function getTimestamp(address stakerAddr) external view returns (uint256);

  /* ===================================================================================
     ============================= EVENTS/MODIFIERS ====================================
     =================================================================================== */

    // Staked event
    event Staked  (address stakerAddr, uint256 amount, uint256 totalAmount);
    // Unstaked event
    event Unstaked(address stakerAddr, uint256 amount);
    // New APY event
    event NewAPY(uint256 apy);
}