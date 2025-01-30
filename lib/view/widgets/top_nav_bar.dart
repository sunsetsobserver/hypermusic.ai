import 'dart:async'; //classes for working with asynchronous operations (like Future and Timer)
import 'package:flutter/material.dart'; //core Flutter Material Design widgets and themes
import 'package:provider/provider.dart'; //Provider package, allowing access to MetaMaskProvider data in widgets
import '../../providers/meta_mask_provider.dart'; //MetaMaskProvider class that manages MetaMask state
import 'dart:html'
    as html; //allows direct access to HTML window and document objects in a web environment, used here to open external links

class TopNavBar extends StatefulWidget implements PreferredSizeWidget {
  final bool
      showPagesLinks; //controls whether navigation links (e.g., “edit”, “explore”) are displayed in the navigation bar (they are not on the opening page)

  TopNavBar({this.showPagesLinks = false});

  @override
  TopNavBarState createState() =>
      TopNavBarState(); //state class that will manage TopNavBar's dynamic behavior

  @override
  Size get preferredSize => Size.fromHeight(
      60); //tells any parent (like an AppBar) how tall the widget should be. This is required because the widget is used as an AppBar substitute.
}

class TopNavBarState extends State<TopNavBar> {
  OverlayEntry?
      _overlayEntry; //a reference to an OverlayEntry which will show the dropdown menu when hovered over
  bool _isButtonHovered =
      false; //booleans to track if the mouse is currently over the wallet button area or the dropdown menu area
  bool _isMenuHovered = false;

  void _showMenu(BuildContext context, MetaMaskProvider metaMask) {
    //creates and inserts an overlay entry for the dropdown menu that appears when the user hovers over the wallet button (if connected)
    _overlayEntry = OverlayEntry(
      //defines a widget that can be placed above the current UI
      builder: (context) => Positioned(
        top: kToolbarHeight,
        right:
            20, //places the overlay just below the app bar at the top-right side of the screen
        child: MouseRegion(
          // around the menu sets _isMenuHovered = true on mouse enter and _isMenuHovered = false on mouse exit
          onEnter: (event) {
            setState(() {
              _isMenuHovered = true;
            });
          },
          onExit: (event) {
            setState(() {
              _isMenuHovered = false;
            });
            Future.delayed(Duration(milliseconds: 100), () {
              //check is performed after 100ms when the mouse leaves the menu area. If neither button nor menu is hovered, _hideMenu() is called to remove the overlay.
              if (!_isButtonHovered && !_isMenuHovered) {
                _hideMenu();
              }
            });
          },
          child: Material(
            //The menu itself is a Material widget with a white background and a shadow:
            color: Colors.white,
            elevation: 4,
            child: ConstrainedBox(
              //ConstrainedBox and IntrinsicWidth ensure the menu has proper sizing:
              constraints: BoxConstraints(maxWidth: 200),
              child: IntrinsicWidth(
                child: Column(
                  //Inside the Column are ListTile widgets offering “Profile” and “Log Out” options:
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text('Profile'),
                      //Tapping “Profile” navigates to /profile:
                      onTap: () {
                        _hideMenu();
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    ListTile(
                      title: Text('Log Out'),
                      //Tapping “Log Out” calls metaMask.logOut() and then navigates back to opening page'/':
                      onTap: () {
                        _hideMenu();
                        metaMask.logOut();
                        Navigator.pushNamed(context, '/');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMenu() {
    //removes the overlay menu from the screen and resets both hover states
    _overlayEntry
        ?.remove(); //? checks if _overlayEntry is not null before removing it
    _overlayEntry = null;
    setState(() {
      //updates the state variables so that next time, the menu won’t be shown until hovered again
      _isButtonHovered = false;
      _isMenuHovered = false;
    });
  }

  Widget _buildWalletButton(MetaMaskProvider metaMask, BuildContext context) {
    //reates an IconButton that shows a wallet icon
    return IconButton(
      //If metaMask.isConnected is true, it shows a different icon and color (green). Otherwise, it uses a blue color and a different icon
      icon: Icon(
        metaMask.isConnected
            ? Icons.account_balance_wallet_outlined
            : Icons.account_balance_wallet,
        color: metaMask.isConnected ? Colors.green : Color(0xFF007BFF),
      ),
      onPressed: () async {
        //If the wallet is not connected, tapping the button attempts to connect to MetaMask
        if (!metaMask.isConnected) {
          if (metaMask.isEnabled) {
            await metaMask.connect();
            if (context.mounted) {
              //If connection is successful, the user is navigated to /explore
              Navigator.pushNamed(context, '/explore');
            }
          } else {
            //If MetaMask is not enabled or not available, a snackbar notifies the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("MetaMask is not available in this browser.")),
            );
          }
        }
      },
    );
  }

  Widget _buildNavLinks(BuildContext context, bool useIcons) {
    //creates a row of navigation controls.
    if (useIcons) {
      //If useIcons is true (generally on narrow screens), it shows IconButtons.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/edit'),
          ),
          IconButton(
            icon: Icon(Icons.travel_explore, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/explore'),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/trade'),
          ),
          IconButton(
            icon: Icon(Icons.school, color: Colors.black),
            onPressed: () {
              html.window.open('https://pt-docs.netlify.app/', '_self');
            },
          ),
        ],
      );
    } else {
      // If useIcons is false (wider screens), it shows TextButtons.
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/edit'),
            child: Text('edit', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/explore'),
            child: Text('explore', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/trade'),
            child: Text('trade', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              html.window.open('https://pt-docs.netlify.app/', '_self');
            },
            child: Text('learn', style: TextStyle(color: Colors.black)),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method is where the UI for the top navigation bar is constructed
    final width = MediaQuery.of(context).size.width; //checks the screen width
    final bool useIcons = width <
        600; //determines if the nav links should be icons or text based on screen width (mobile vs desktop)
    final metaMask = Provider.of<MetaMaskProvider>(
        context); //gets the current MetaMask state from the provider, so the nav bar can react to whether the wallet is connected or not

    return AppBar(
      //Returns an AppBar widget customised:
      automaticallyImplyLeading: false, //means no default back button is shown
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0, //removes default padding around the title area
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            GestureDetector(
              //on the title text “hypermusic.ai” allows navigation back to the home page ('/')
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
              child: Text(
                'hypermusic.ai',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Spacer(), //create flexible space to push widgets apart
            if (widget.showPagesLinks)
              _buildNavLinks(context,
                  useIcons), //if showPagesLinks is true, the nav links are displayed
            Spacer(), //create flexible space to push widgets apart
            if (useIcons) //If useIcons is true, it directly displays the _buildWalletButton
              _buildWalletButton(metaMask, context)
            else // If useIcons is false, it shows a MouseRegion with hover detection
              MouseRegion(
                onEnter: (event) {
                  //onEnter on the MouseRegion sets _isButtonHovered = true and shows the menu if the wallet is connected
                  if (metaMask.isConnected) {
                    setState(() {
                      _isButtonHovered = true;
                    });
                    _showMenu(context, metaMask);
                  }
                },
                onExit: (event) {
                  //onExit sets _isButtonHovered = false and after a short delay, if neither button nor menu is hovered, _hideMenu() is called
                  setState(() {
                    _isButtonHovered = false;
                  });
                  // Delay checking if we should hide the menu
                  Future.delayed(Duration(milliseconds: 100), () {
                    if (!_isButtonHovered && !_isMenuHovered) {
                      _hideMenu();
                    }
                  });
                },
                child: ElevatedButton(
                  //shows either the connected wallet address or “Connect Wallet” if not connected.
                  onPressed: metaMask
                          .isConnected //Clicking it attempts to connect to MetaMask or shows an error snackbar if not available.
                      ? null
                      : () async {
                          if (metaMask.isEnabled) {
                            await metaMask.connect();
                            if (context.mounted) {
                              Navigator.pushNamed(context, '/explore');
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "MetaMask is not available in this browser.")),
                            );
                          }
                        },
                  child: Text(
                    metaMask.isConnected
                        ? metaMask.currentAddress
                        : "Connect Wallet",
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
      centerTitle: false,
    );
  }
}
