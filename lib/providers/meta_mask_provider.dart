import 'package:flutter/material.dart'; //Material UI components, and crucially, ChangeNotifier for state management
import 'package:flutter_web3/flutter_web3.dart'; //provides Web3 functionalities (interaction with Ethereum, MetaMask, accounts, and chains) in a Flutter web environment

class MetaMaskProvider extends ChangeNotifier {
  //making MetaMaskProvider a part of the Flutter's Provider architecture

  static const operatingChain = 1;
  // sets the primary chain ID your app expects to operate on—here, 1 stands for the Ethereum mainnet

  String currentAddress = '';
  //holds the currently connected Ethereum address from MetaMask. Initially empty, meaning no account is connected

  int currentChain = -1;
  //stores the currently connected chain ID. -1 indicates no valid chain is connected yet

  bool get isEnabled => ethereum != null;
  //checks if the ethereum object (injected by MetaMask) is available. If ethereum is not null, it means the browser has access to an Ethereum provider (like MetaMask)

  bool get isConnected => isEnabled && currentAddress.isNotEmpty;
  // returns true if MetaMask is enabled and an address is set, meaning the user is connected to MetaMask

  bool get isInOperatingChain => currentChain == operatingChain;
  //returns true if the currently connected chain matches the operatingChain (here, Ethereum mainnet).

  Future<void> connect() async {
    //an asynchronous method to request an account connection from MetaMask
    if (isEnabled) {
      //checks if MetaMask is available

      final accounts = await ethereum!.requestAccount();
      // prompts MetaMask to request the user to connect their account. If successful, accounts will be a list of strings containing the user’s Ethereum addresses

      if (accounts.isNotEmpty) {
        //ensures that at least one address was returned

        currentAddress = accounts.first;
        //retrieves the chain ID of the connected network and updates currentChain.

        currentChain = await ethereum!.getChainId();
        //retrieves the chain ID of the connected network and updates currentChain

        notifyListeners();
        // notifies any UI or listeners that the provider’s state has changed (so widgets that depend on isConnected, currentAddress, etc. will update)
      }
    }
  }

  void logOut() {
    //resets the provider’s state to indicate that no account is currently connected
    currentAddress = ''; // Clear the address
    currentChain = -1; // Reset the chain ID
    notifyListeners(); // Notify listeners to update UI
  }

  void reset() {
    currentAddress = '';
    currentChain = -1;
    notifyListeners();
  }

  void start() {
    ethereum?.onAccountsChanged((accounts) {
      //registers a callback that fires whenever the user switches accounts in MetaMask. When that happens, the provider calls reset() to clear the state and prompt the user to reconnect or re-identify themselves
      reset();
    });
    ethereum?.onChainChanged((chainId) {
      // registers a callback for when the chain/network changes. When the user switches networks in MetaMask, reset() is called to ensure the UI reflects that the currently stored chain or address may no longer be valid or relevant
      reset();
    });
  }
}
