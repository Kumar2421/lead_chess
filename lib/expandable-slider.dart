import 'package:flutter/material.dart';
import 'package:expandable_slider/expandable_slider.dart';
import 'package:chess_game/colors.dart';

class ExpandSlider extends StatefulWidget {

  final double max;
  final double min;
  final String? name;
  final String? time;
  final String? value;
  const ExpandSlider({super.key, required this.max, required this.min, this.name, this.time, this.value});

  @override
  State<ExpandSlider> createState() => _ExpandSliderState();
}

class _ExpandSliderState extends State<ExpandSlider> {
  late double _value;

  @override
  void initState() {
    _value = widget.min;
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.name ?? "Initial Time ",
                    style: TextStyle(color: Colors.white,)),
                Text(
                    _value.toStringAsFixed(0),
                    style: TextStyle(color: Colors.white,)
                  //Theme.of(context).textTheme.headline4,
                ),
                Text(widget.time ?? ' min',
                    style: TextStyle(color: Colors.white,))
              ],
            ),

            //SizedBox(height: 5),
            // SliderTheme(
            //   data: SliderThemeData(
            //     trackHeight: 5, // Adjust the height of the track
            //     thumbShape: RoundSliderThumbShape(
            //       enabledThumbRadius: 10, // Adjust the size of the thumb
            //     ),
            //   ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: MediaQuery
                      .of(context)
                      .size
                      .width / 30),
                  child: Text('0', style: TextStyle(color: Colors.white,)),
                ),
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 1.5,
                  child: ExpandableSlider.adaptive(
                    value: _value,
                    onChanged: _onChanged,
                    min: widget.min,
                    max: widget.max,
                    estimatedValueStep: 1,
                    activeColor: Colors.orangeAccent,
                    inactiveColor: color.navy1.withOpacity(0.15),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: MediaQuery
                      .of(context)
                      .size
                      .width / 30),
                  child: Text(widget.value ?? '120',
                      style: TextStyle(color: Colors.white,)),
                ),

              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the next page and pass the selected initial time
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NextPage(initialTime: _value),
                  ),
                );
              },
              child: const Text("Check"),
            ),
            // const SizedBox(height: 32),
            // ElevatedButton(
            //   onPressed: () => _onChanged(widget.max / 2),
            //   child: const Text("Jump to half"),
            // ),
          ],
        ),
      );

  void _onChanged(double newValue) {
    setState(() => _value = newValue);
  }
}

class NextPage extends StatelessWidget {
  final double initialTime;

  const NextPage({Key? key, required this.initialTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Initial Time: $initialTime'),
            // ... Add more widgets as needed
          ],
        ),
      ),
    );
  }
}