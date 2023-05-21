import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minor/screens/pages/account_screen.dart';
import 'package:minor/screens/pages/chats_home.dart';
import 'package:minor/screens/pages/home_screen.dart';
import 'package:minor/views/widgets/custom_appBar.dart';
import '../../const/color_const.dart';
import '../../models/form_model.dart';
import 'category_screen.dart';

class MyAds extends StatefulWidget {
  final User user;

  const MyAds({super.key, required this.user});

  @override
  State<MyAds> createState() => _MyAdsState();
}

class _MyAdsState extends State<MyAds> {
  String? name = ' ';
  String? email = ' ';
  String? bio = ' ';
  String? profilePic = ' ';
  String? phoneNumber = ' ';
  String? aadhar = ' ';
  String? uid = ' ';

  Future _getData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        name = data['name'];
        aadhar = data['aadhar'];
        bio = data['bio'];
        email = data['email'];
        profilePic = data['profilePic'];
        phoneNumber = data['phoneNumber'];
        uid = data['uid'];
      });
    }
  }

  int _selectedPageIndex = 3;
  void _selectPage(int index) {
    if (index == 0) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return HomeScreen(
              category: "NULL",
            );
          },
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ChatHome(user: widget.user);
          },
        ),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AccountScreen(
                email: email,
                profilePic: profilePic,
                aadhar: aadhar,
                phoneNumber: phoneNumber,
                bio: bio,
                name: name!,
                uid: uid,);
          },
        ),
      );
    }

    // setState(() {
    //   _selectedPageIndex = index;
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(name: "MY ADS"),
      body: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("product")
                .where("uid", isEqualTo: widget.user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot datasnapshot = snapshot.data as QuerySnapshot;
                  if (datasnapshot.docs.length > 0) {
                    print(datasnapshot.docs.length);
                    return ListView.builder(
                      itemCount: datasnapshot.docs.length,
                      itemBuilder: (context, index) {
                        FormModel formmodel = FormModel.fromMap(
                            datasnapshot.docs[index].data()
                                as Map<String, dynamic>);
                        //print(index.toString());
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadiusDirectional.circular(20),
                            ),
                            color: Color.fromARGB(255, 229, 238, 238),
                            child: Row(
                              children: [
                                Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                        formmodel.profilepic.toString(),
                                      ),
                                      // image: AssetImage(
                                      //     "assets/images/img11.png"),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        formmodel.productName.toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "₹ " +
                                            formmodel.price.toString() +
                                            " " +
                                            formmodel.duration.toString(),
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 15,
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Text(formmodel.location.toString(),
                                              style: TextStyle(
                                                color: Colors.black,
                                              )),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    //print(2);
                    return const Center(
                      child: Text("Upload Your Products",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300)),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  // print(1);
                  return const Text("No ADS");
                }
              } else {
                return Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    ColorConst.primaryColor,
                  ),
                ));
              }
            }),
      ),
      bottomNavigationBar: BottomAppBar(
        // color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 0.01,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: kBottomNavigationBarHeight * 1.1,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
              //  borderRadius: BorderRadius.circular(20),
            ),
            child: BottomNavigationBar(
              onTap: _selectPage,
              backgroundColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.black54,
              selectedItemColor: ColorConst.primaryColor,
              currentIndex: _selectedPageIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble),
                  label: 'Chats',
                ),
                const BottomNavigationBarItem(
                  activeIcon: null,
                  icon: Icon(null),
                  label: 'Rent Now',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.favorite_border,
                  ),
                  label: 'My Ads',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          backgroundColor: ColorConst.primaryColor,
          hoverElevation: 10,
          splashColor: Colors.grey,
          tooltip: 'Rent',
          elevation: 4,
          child: Icon(Icons.add),
          onPressed: () => setState(() {
            _selectedPageIndex = 2;
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CategoryScreen(firebaseuser: widget.user)),
            );
            // CategoryScreen());
          }),
        ),
      ),
    );
  }
}
