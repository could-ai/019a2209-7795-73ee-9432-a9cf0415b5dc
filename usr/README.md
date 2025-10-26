# couldai_user_app

A financial calculator app for mean reversion and zone strength analysis with live market data.

## Features

- Live data collection from multiple markets: Forex, Stocks, Futures, and Crypto
- Mean reversion calculator with Bollinger Bands
- Supply and demand zone strength analysis
- Interactive charts for visualization

## Getting Started

1. Get an API key from [Alpha Vantage](https://www.alphavantage.co/support/#api-key)
2. Replace `YOUR_API_KEY_HERE` in `lib/providers/market_data_provider.dart` with your actual API key
3. Run `flutter pub get` to install dependencies
4. Run the app with `flutter run`

## Usage

1. Select a market type (Forex, Stocks, Futures, or Crypto)
2. Enter a symbol (e.g., AAPL for Apple stock, EUR for Euro)
3. Fetch live data
4. Open the calculator to perform mean reversion and zone strength analysis

## Calculations

- **Mean Reversion**: Uses Z-score to determine how far the current price deviates from the mean
- **Zone Strength**: Calculates supply and demand zone strength based on price position relative to Bollinger Bands
- **Bollinger Bands**: Upper and lower bands based on moving average and standard deviation

## Note

This app uses mock historical data for calculations. For production use, integrate with a historical data API.
