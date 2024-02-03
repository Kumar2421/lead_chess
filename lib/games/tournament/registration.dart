import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';

import '../../buttons/back_button.dart';


class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 4, vsync: this);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return
      //MaterialApp(
      // home: DefaultTabController(
      //   length: 4,
     //   child:
        Scaffold(
          appBar: AppBar(
            // bottom: const TabBar(
            //   indicatorColor: Colors.orange,
            //   labelColor: Colors.orange,
            //   tabs: [
            //     Tab(
            //       icon: Icon(Icons.info),
            //       child: Text('Status'),
            //     ),
            //     Tab(
            //       icon: Icon(Icons.workspace_premium),
            //       child: Text('Prize'),
            //     ),
            //     Tab(
            //       icon: Icon(Icons.person),
            //       child: Text('Players'),
            //     ),
            //     Tab(
            //       icon: Icon(Icons.table_bar),
            //       child: Text('Table'),
            //     )
            //   ],
            // ),
            backgroundColor: color.navy1,
            elevation: 5,
            title: const Text('Tournaments'),
            leading: ArrowBackButton(color: Colors.white,),
          ),
          body:Column(
            children: [
              Container(
                color: Colors.black.withOpacity(0.5),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: color.navy1,
                  labelColor: color.navy1,
                  unselectedLabelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Row(
                        children: [
                          Icon(Icons.info,size: 20,),
                          Text('Status'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(Icons.workspace_premium,size: 20,),
                          Text('Prize'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(Icons.person,size: 20,),
                          Text('Players'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(Icons.table_bar,size: 20,),
                          Text('Table'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: double.maxFinite,
                height: screenHeight/1.208,
                child: TabBarView(
                  controller: _tabController,
                    children: [
                      Status(),
                      Prize(),
                      Player(),
                      Table()
                    ],
                  ),
              )
            ],
          ),

          //
          // TabBarView(
          //   children: [
          //     Status(),
          //     Prize(),
          //     Player(),
          //     Table()
          //   ],
          // ),
      //  ),
    //  ),
    );
  }
}

class Status extends StatefulWidget {
  const Status({super.key});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: screenHeight/1,
        width: screenWidth/1,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
        ),
        child: Column(
          children: [
            SizedBox(height: screenHeight/20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: screenHeight/20,
                  width: screenWidth/4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5)
                  ),
                  child: Center(child: Text('Players: \n8/8',style: TextStyle(color: Colors.white),)),
                ),
                Container(
                  height: screenHeight/20,
                  width: screenWidth/4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5)
                  ),
                  child: Center(child: Text('Buy-in: \n150',style: TextStyle(color: Colors.white),)),
                ),
                Container(
                  height: screenHeight/20,
                  width: screenWidth/4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5)
                  ),
                  child: Center(child: Text('Prize pool: \n1000',style: TextStyle(color: Colors.white),)),
                ),
              ],
            ),
            SizedBox(height: screenHeight/20,),
            Container(
              height: screenHeight/3,
              width: screenWidth/1.15,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5)
              ),
              child: Padding(
                padding:  EdgeInsets.only(left: screenWidth/20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registration at:    late Registration: 30 min',style: TextStyle(color: Colors.white),),
                    Text('Tournament Start:   Start in 8AM',style: TextStyle(color: Colors.white),),
                    Text('Entry fee:   100',style: TextStyle(color: Colors.white),),
                    Text('Min Players:  2',style: TextStyle(color: Colors.white),),
                    Text('Max Players:  8',style: TextStyle(color: Colors.white),)
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight/20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  onPressed: (){},
                  child: Text('CASHIER'),
                  color: color.navy,
                  height: screenHeight/23,
                  minWidth: screenWidth/2.5,
                ),
                MaterialButton(
                    onPressed: (){},
                  child: Text('REGISTRATION'),
                  color: color.navy,
                  height: screenHeight/23,
                  minWidth: screenWidth/2.5,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class User {
  final String username;
  final String imageUrl;
  final String prize;

  const User( {
    required this.prize,
    required this.username,
    required this.imageUrl,});
}

class Prize extends StatefulWidget {
  const Prize({super.key});

  @override
  State<Prize> createState() => _PrizeState();
}

class _PrizeState extends State<Prize> {
  List<User> users=[
    const User(username: '1st', imageUrl: 'assets/leader.png',prize: 'prize: 500'),
    const User(username: '2nd',  imageUrl: 'assets/leader.png',prize: 'prize: 300'),
    const User(username: '3rd',  imageUrl: 'assets/leader.png',prize: 'prize: 200'),
  ];
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: screenHeight/1,
        width: screenWidth/1,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
        ),
        child: Column(
          children: [
            SizedBox(height: screenHeight/50,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image(image: AssetImage('assets/leader.png'),height: screenHeight/20,width: screenWidth/10,),
                Text('TOTAL PRIZE POOL:',style: TextStyle(color: Colors.white),),
                Text('1000',style: TextStyle(color: Colors.white),)
              ],
            ),
            Container(
              height: screenHeight/2,
              width: screenWidth/1,
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12)
              // ),
              // child: ListView.builder(
              //           itemCount: friends.length,
              //           itemBuilder: (BuildContext context, int index) {
              //             return FriendsList(child: friends[index],);
              //           },
              //         ),
              child:
              ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = users[index];
                  return Container(
                    height: screenHeight/12,
                    width: screenWidth/1.2,
                    decoration: BoxDecoration(
                      color: color.navy1.withOpacity(0.25),
                      border: Border(
                        bottom: BorderSide(color: color.navy1, width: 1.0), // Set the border color and width for the bottom side
                      ),
                    ),
                    child: ListTile(
                      // textColor: color.navy1.withOpacity(0.25),
                      //  contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      // tileColor: color.navy1.withOpacity(0.15),
                      leading: Image(image: AssetImage('assets/leader.png'),height: screenHeight/20,),
                      title: Text(user.username,style: TextStyle(fontSize: 13,color: Colors.white),),
                      trailing: Padding(
                            padding: EdgeInsets.only(top: screenHeight/100),
                            child: Text(user.prize, style: TextStyle(fontSize: 13,color: Colors.white),),
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class User1 {
  final String username;
  final String place;
  final String points;

  const User1( {
    required this.place,
    required this.username,
    required this.points,});
}
class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  List<User1> users=[
    const User1(username: 'name1', place: '1',points: '500'),
    const User1(username: 'name2', place: '2',points: '500'),
    const User1(username: 'name3', place: '3',points: '500'),
  ];
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: screenHeight/1,
        width: screenWidth/1,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
        ),
        child: Column(
          children: [
           // SizedBox(height: screenHeight/50,),
            Padding(
              padding: EdgeInsets.only(left: screenWidth/20,top: screenHeight/40,right: screenWidth/20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('NAME',style: TextStyle(color: Colors.white),),
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth/20),
                    child: Text('PLACE',style: TextStyle(color: Colors.white),),
                  ),
                  Text('POINTS',style: TextStyle(color: Colors.white),)
                ],
              ),
            ),
            Container(
              height: screenHeight/2,
              width: screenWidth/1,
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12)
              // ),
              // child: ListView.builder(
              //           itemCount: friends.length,
              //           itemBuilder: (BuildContext context, int index) {
              //             return FriendsList(child: friends[index],);
              //           },
              //         ),
              child:
              ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = users[index];
                  return Container(
                    height: screenHeight/12,
                    width: screenWidth/1.2,
                    decoration: BoxDecoration(
                      color: color.navy1.withOpacity(0.25),
                      border: Border(
                        bottom: BorderSide(color: color.navy1, width: 1.0), // Set the border color and width for the bottom side
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth/20,right: screenWidth/20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(user.username,style: TextStyle(fontSize: 13,color: Colors.white),),
                          Text(user.place,style: TextStyle(fontSize: 13,color: Colors.white),),
                          Text(user.points, style: TextStyle(fontSize: 13,color: Colors.white),),
                        ],
                      ),
                    )
                    //
                    // ListTile(
                    //   // textColor: color.navy1.withOpacity(0.25),
                    //   //  contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    //   // tileColor: color.navy1.withOpacity(0.15),
                    //   leading:  Text(user.username,style: TextStyle(fontSize: 13,color: Colors.white),),
                    //   title: Text(user.place,style: TextStyle(fontSize: 13,color: Colors.white),),
                    //   trailing: Padding(
                    //     padding: EdgeInsets.only(top: screenHeight/100),
                    //     child: Text(user.points, style: TextStyle(fontSize: 13,color: Colors.white),),
                    //   ),
                    // ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class User2 {
  final String username;
  final String place;
  final String points;

  const User2( {
    required this.place,
    required this.username,
    required this.points,});
}
class Table extends StatefulWidget{
  const Table({super.key});

  @override
  State<Table> createState() => _TableState();
}

class _TableState extends State<Table> {
  List<User2> users=[
    const User2(username: '8456', place: '100',points: '500'),
    const User2(username: '3875', place: '200',points: '500'),
    const User2(username: '4497', place: '300',points: '500'),
  ];
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: screenHeight/1,
        width: screenWidth/1,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
        ),
        child: Column(
          children: [
            SizedBox(height: screenHeight/50,),
            Padding(
              padding: EdgeInsets.only(left: screenWidth/20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ID',style: TextStyle(color: Colors.white),),
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth/10),
                    child: Text('MIN.POINTS',style: TextStyle(color: Colors.white),),
                  ),
                  Text('MAX.POINTS',style: TextStyle(color: Colors.white),)
                ],
              ),
            ),
            Container(
              height: screenHeight/2,
              width: screenWidth/1,
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12)
              // ),
              // child: ListView.builder(
              //           itemCount: friends.length,
              //           itemBuilder: (BuildContext context, int index) {
              //             return FriendsList(child: friends[index],);
              //           },
              //         ),
              child:
              ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = users[index];
                  return Container(
                      height: screenHeight/12,
                      width: screenWidth/1.2,
                      decoration: BoxDecoration(
                        color: color.navy1.withOpacity(0.25),
                        border: Border(
                          bottom: BorderSide(color: color.navy1, width: 1.0), // Set the border color and width for the bottom side
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: screenWidth/20,right: screenWidth/20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.username,style: TextStyle(fontSize: 13,color: Colors.white),),
                            Text(user.place,style: TextStyle(fontSize: 13,color: Colors.white),),
                            Text(user.points, style: TextStyle(fontSize: 13,color: Colors.white),),
                          ],
                        ),
                      )
                    //
                    // ListTile(
                    //   // textColor: color.navy1.withOpacity(0.25),
                    //   //  contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    //   // tileColor: color.navy1.withOpacity(0.15),
                    //   leading:  Text(user.username,style: TextStyle(fontSize: 13,color: Colors.white),),
                    //   title: Text(user.place,style: TextStyle(fontSize: 13,color: Colors.white),),
                    //   trailing: Padding(
                    //     padding: EdgeInsets.only(top: screenHeight/100),
                    //     child: Text(user.points, style: TextStyle(fontSize: 13,color: Colors.white),),
                    //   ),
                    // ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}