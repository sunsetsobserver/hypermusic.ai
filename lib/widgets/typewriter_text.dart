import 'dart:async'; //classes for working with asynchronous operations, such as Timer.
import 'package:flutter/material.dart'; //Material package for widgets and theming

class TypewriterText extends StatefulWidget {
  //TypewriterText is a StatefulWidget that displays text with a typewriter-like effect
  final List<String>
      texts; //a list of strings that the typewriter will cycle through
  final Duration
      period; //sets how long the widget should wait before starting to “delete” the current text and move on to the next one

  const TypewriterText({
    super.key,
    required this.texts,
    required this.period,
  });

  @override
  TypewriterTextState createState() => TypewriterTextState();
}

class TypewriterTextState extends State<TypewriterText> {
  //manages the widget’s dynamic behavior, like starting and stopping typing animations
  late Timer
      _timer; //declares a Timer that will run periodically to update the text
  int _loopNum =
      0; //tracks which text in the texts list is currently being typed or deleted. As _loopNum increments, the widget moves on to the next string in texts
  bool _isDeleting =
      false; //indicates if the widget is currently removing characters (deleting) rather than adding them
  String _currentText =
      ''; //holds the currently displayed substring of the selected fullTxt

  @override
  void initState() {
    //called when the widget is inserted into the widget tree
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    //initiates the typing animation as soon as the widget is ready
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      //sets up a recurring Timer that fires every 100 milliseconds
      final fullTxt = widget.texts[_loopNum %
          widget.texts
              .length]; //selects the current full text string from the texts list. Using % widget.texts.length cycles through the list if _loopNum exceeds the list length

      setState(() {
        //ensures that changes to _currentText, _isDeleting, and _loopNum update the UI
        if (_isDeleting) {
          ////If _isDeleting is true (we are deleting text)
          if (_currentText.isNotEmpty) {
            //If _currentText still has characters, remove one character at a time by creating a substring that is one character shorter
            _currentText = fullTxt.substring(0, _currentText.length - 1);
          } else {
            //If _currentText becomes empty, it means we’ve finished deleting the current word. We switch _isDeleting = false and move to the next text by incrementing _loopNum.
            // Finished deleting; go to next text
            _isDeleting = false;
            _loopNum++;
          }
        } else {
          //If _isDeleting is false (we are typing forward)
          if (_currentText.length < fullTxt.length) {
            //If _currentText.length < fullTxt.length, we add another character to _currentText from fullTxt
            _currentText = fullTxt.substring(0, _currentText.length + 1);
          } else {
            //If we’ve reached the end of fullTxt (i.e., _currentText is as long as fullTxt), we wait for the specified widget.period, then start deleting by setting _isDeleting = true.
            // Wait and then start deleting
            Future.delayed(widget.period, () {
              // introduces a pause before starting the deletion process, making the typed word remain fully visible for a given time
              if (mounted) {
                setState(() {
                  _isDeleting = true;
                });
              }
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    //is called when the widget is removed from the widget tree
    _timer
        .cancel(); //stops the timer to prevent memory leaks or updates after the widget is gone
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //returns a Text widget that displays the current state of _currentText
    return Text(
      _currentText,
      textAlign: TextAlign.center, //centers the text horizontally
      style: TextStyle(
        //ets the font size and line height. There is no other formatting since the effect is purely about changing the displayed text over time
        fontSize: 24,
        height: 1.3,
      ),
    );
  }
}
