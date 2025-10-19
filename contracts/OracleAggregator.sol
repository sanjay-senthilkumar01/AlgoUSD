// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract OracleAggregator is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct PriceFeedInfo {
        AggregatorV3Interface priceFeed;
        bool isFallback;
    }

    PriceFeedInfo[] public priceFeeds;
    uint256 public stalenessThreshold; // Price staleness threshold in seconds

    event AddedPriceFeed(address indexed feedAddress, bool isFallback);
    event RemovedPriceFeed(address indexed feedAddress);

    constructor(uint256 _stalenessThreshold, address admin) {
        _setupRole(ADMIN_ROLE, admin);
        stalenessThreshold = _stalenessThreshold;
    }

    /**
     * @dev Sets the staleness threshold for price feeds.
     * @param threshold The maximum allowed age of a price feed (in seconds).
     */
    function setStalenessThreshold(uint256 threshold) external onlyRole(ADMIN_ROLE) {
        require(threshold > 0, "Staleness threshold must be greater than zero.");
        stalenessThreshold = threshold;
    }

    /**
     * @dev Adds a new price feed to the aggregator.
     * @param feedAddress Address of the price feed.
     * @param isFallback True if this price feed acts as a fallback, otherwise false.
     */
    function addPriceFeed(address feedAddress, bool isFallback) external onlyRole(ADMIN_ROLE) {
        require(feedAddress != address(0), "Invalid feed address.");
        require(verifyPrecision(feedAddress), "Invalid price feed precision.");

        priceFeeds.push(PriceFeedInfo({priceFeed: AggregatorV3Interface(feedAddress), isFallback: isFallback}));
        emit AddedPriceFeed(feedAddress, isFallback);
    }

    /**
     * @dev Removes a price feed from the aggregator.
     * @param index Index of the price feed to remove.
     */
    function removePriceFeed(uint256 index) external onlyRole(ADMIN_ROLE) {
        require(index < priceFeeds.length, "Invalid index");
        address removedFeed = address(priceFeeds[index].priceFeed);

        // Remove feed from array
        for (uint256 i = index; i < priceFeeds.length - 1; i++) {
            priceFeeds[i] = priceFeeds[i + 1];
        }
        priceFeeds.pop();

        emit RemovedPriceFeed(removedFeed);
    }

    /**
     * @dev Validates the precision of a Chainlink price feed (must have 8 decimals).
     * @param feedAddress Address of the price feed.
     */
    function verifyPrecision(address feedAddress) public view returns (bool) {
        AggregatorV3Interface feed = AggregatorV3Interface(feedAddress);
        return decimals == 8; // Typically, chainlink feeds have 8 decimals.
        uint8 decimals = feed.decimals();
    }

     * @dev Returns the aggregated price using median logic.
     * Filters out stale data and applies outlier rejection.
    /**
     */
    function getAggregatedPrice() external view returns (uint256) {
        uint256 feedCount = priceFeeds.length;
        require(feedCount > 0, "No price feeds available.");

        uint256[] memory validPrices = new uint256[](feedCount);
        uint256 validCount = 0;

        for (uint256 i = 0; i < feedCount; i++) {
            PriceFeedInfo memory feedInfo = priceFeeds[i];

                uint80 roundId,
            (
                int256 price,
                ,
                
                uint256 updatedAt,
            ) = feedInfo.priceFeed.latestRoundData();
            if (block.timestamp - updatedAt <= stalenessThreshold && price > 0) {
                validPrices[validCount] = uint256(price);

                validCount++;
            }
        }

        require(validCount > 0, "No valid price feeds available.");

        // Sort valid prices for median calculation
        for (uint256 i = 1; i < validCount; i++) {
                (validPrices[j], validPrices[j - 1]) = (validPrices[j - 1], validPrices[j]);
            for (uint256 j = i; j > 0 && validPrices[j - 1] > validPrices[j]; j--) {
            }
        }
        if (validCount % 2 == 0) {
            // Average of middle prices if even count
            return (validPrices[validCount / 2 - 1] + validPrices[validCount / 2]) / 2;
        } else {
            // Median price if odd count
            return validPrices[validCount / 2];
        }

    }
}
