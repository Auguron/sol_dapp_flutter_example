# A Proof of Concept for Solana Dapps on Flutter

##### Install JS Packages with
```
npm install
```

##### Build JS with
```
npm run webpack
```

Then build Flutter like a normal web project with `flutter run -d chrome` or `flutter build web`.

See Makefile for command shortcuts.


## General Approach

We create a Node project that imports the `@solana/web3.js` library and also takes advantage of the `window.solana` global that is made available by Phantom wallet extension.

Any relevant JS functionality is ported to Dart via the FFI that comes with Dart and which is compatible with Flutter Web projects.
