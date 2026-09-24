# Beauty Essentials

A small Flutter product catalog app. 
You slide to unlock, browse a list of products, search, sort, filter by price, open a product, and add things to a bag. 
There's no checkout. The bag is just for viewing.

## How to run

You need Flutter installed and an emulator, Chrome, or Windows desktop set up. I built it on Flutter 3.47.5 (Dart 3.13.4). 

```
flutter pub get
flutter run -d emulator-5554
```

Swap the device for `chrome` or `windows` if you want to run it there. `flutter devices` shows what you have.
Packages I used: `http` and `google_fonts`. The fonts get downloaded the first time the app runs, so the first launch needs internet (the API needs it anyway).
If you build a release APK, check that `AndroidManifest.xml` has the INTERNET permission. Debug has it by default, release might not.
I tested on the Android 15 emulator, Chrome, and Windows.

## Stack

- Flutter, Material 3
- Plain `ChangeNotifier` for state, no extra state management package
- `http` for the API calls
- `google_fonts` (Poppins, Playfair Display, Lobster Two)
- DummyJSON as the backend

## Folder layout

```
lib/
  main.dart
  data/
    api/          service_api.dart, item_data_api.dart
    items/        product_item.dart (the repository)
    models/       product.dart
  view/
    controllers/  product_list_controller.dart, cart_controller.dart
    screens/      unlock_screen, product_list_screen, product_detail_screen, bag_screen
    widgets/      fancy_widgets, product_card, state_widgets
test/
  test_helpers.dart, product_test.dart, cart_controller_test.dart,
  product_list_controller_test.dart, unlock_screen_test.dart
```

## Why I built it this way

**Three layers.** 
The API classes only do HTTP, the repository turns JSON into `Product` objects, and the controllers hold the state. 
Screens just draw stuff and pass taps along. That way the UI never touches raw maps.

**ChangeNotifier only.** 
The app is small so I didn't want to pull in Provider or Bloc just for this. 
The list screen owns its controller. The cart is a singleton (`CartController.instance`) because the list, detail and bag screens all need it.

**A view state enum.** 
The list is always in one of four states: loading, success, empty, error. 
Makes the screen code easy to follow and the transitions easy to animate.

**Request IDs.** 
Every time a new load starts (new search, sort change, refresh) I bump a counter. 
If an older request finishes late, its result gets thrown away. Without this you get old search results showing up over new ones.

**Debounced search.** 
It waits 400ms after you stop typing before hitting the API.

**Infinite scroll.** 
Next page loads when you're within 200px of the bottom, 20 items per page. 
If loading more fails, it keeps what you already have instead of replacing everything with an error.

**Sorting on the server, price filter on the client.** 
DummyJSON supports `sortBy` and `order`, but has no price range option. 
So sorting goes through the API and the price filter runs on the loaded products. Problem is a narrow price range can leave almost nothing on screen, so the controller keeps fetching pages until at least 8 items match (or runs out, or hits a limit of 15 pages).

**Detail screen shows the preview first.** 
When you tap a product I pass along the one already loaded, so the screen appears instantly with the hero animation, 
then the full details load in behind it.

**Shared widgets.** 
Colors, glass panels, press animations and loading skeletons live in `fancy_widgets.dart` and `state_widgets.dart` so the screens look the same.

## Tests

```
flutter test
```

You can also run one file, e.g. `flutter test test/cart_controller_test.dart`, or add `--coverage` to get a coverage report.

What's covered:
- `product_test.dart`: `Product.fromJson` defaults, parsing prices that come as strings, and `hasMore`.
- `cart_controller_test.dart`: add, increment, decrement, remove, clear, subtotal, and listeners getting notified. 
The cart is a singleton so each test clears it first.
- `product_list_controller_test.dart`: first load, empty, error, load more, search debounce, sort, and the price filter fetching extra pages.
- `unlock_screen_test.dart`: a short drag snaps back, a full drag unlocks.

## What's not done

- No checkout or payment. Bag is view only.
- The bag isn't saved. Close the app and it's gone.
- The price filter is done on the phone, not the API, so a tight range can trigger a lot of page fetching and still show fewer than 8 items.
- No offline mode or caching.
- Error messages are just the exception text, nothing friendly per error type.


## API endpoints used

- List: `GET https://dummyjson.com/products?limit=20&skip=0&sortBy=price&order=asc`
- Search: `GET https://dummyjson.com/products/search?q=phone&sortBy=title&order=asc`
- Detail: `GET https://dummyjson.com/products/{id}`