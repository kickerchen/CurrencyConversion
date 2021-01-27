# CurrencyConversion

This project is using MVVM structure, CocoaPods for dependency management.

So please run command `pod install` and open project from `.xcworkspace` instead of `.xcodeproj`.

Pods will install RxSwift, Realm, Alamofire.

## Project Structure

### UI

- CurrencyViewController: The main view with a label to show/pick currency, a textfield to input amount, and grids to show rates. 
- CurrencyPickerView: A list for choosing a currency.
- CurrencyQuoteCell: The custom collection cell to display each rate.
- CustomKeyboard: A custom numeric input with 2 additional buttons dismiss and convert.

### Model

- Currency: A realm model to keep a currency's code & country name.
- Quote: A realm model to keep a quote's code pair & rate.

### Service

- CurrencyFetchService: The networking serivce to fetch live data.
- CurrencyFetchScheduler: The scheduling service to manage data update (frequency: 2 hours).

### Unit Test (CurrencyConversionTests)

- CurrencyViewModelTest
- CurrencyPickerViewModelTest
- CurrencyFetchServiceTest
- CurrencyFetchSchedulerTest

## Screenshot

<img src="https://user-images.githubusercontent.com/2072087/105940707-dd5aac00-6096-11eb-9b74-38b4289ec847.png" width="360">
