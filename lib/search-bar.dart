
import 'package:flutter/material.dart';
class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  @override
  Widget build(BuildContext context) {

    return  Padding(padding: EdgeInsets.all(8.0),
      child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              hintText: 'Search for Products',
              leading: const Icon(Icons.search),
              trailing: <Widget>[
                Tooltip(
                  message: 'Change brightness mode',
                  child: IconButton(
                    // isSelected: isDark,
                    onPressed: () {
                      setState(() {
                        //   isDark = !isDark;
                      });
                    },
                    icon: const Icon(Icons.mic),
                    //selectedIcon: const Icon(Icons.brightness_2_outlined),
                  ),
                )
              ],
            );
          },
          suggestionsBuilder: (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(5, (int index) {
              final String item = 'item $index';
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(item);
                  });
                },
              );
            });
          }),
      // child: Card(
      //   elevation: 1,
      //   child: TextField( onTap: (){
      //     Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SearchPage()));
      //   },
      //     decoration: InputDecoration(
      //       enabledBorder: InputBorder.none,
      //       disabledBorder: InputBorder.none,
      //       hintText: 'Search For Products',
      //       filled: true,
      //       fillColor: Colors.white,
      //       prefixIcon: InkWell(
      //           onTap: (){
      //             Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SearchPage()));
      //             },
      //          child: Icon(Icons.search,color: Colors.grey,)),
      //       suffixIcon: InkWell(
      //         onTap: (){},
      //           child: Icon(Icons.mic,color: Colors.grey,),
      //         ),
      //     ),
      //   ),
      // ),
    );
  }
}