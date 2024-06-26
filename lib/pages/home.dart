import 'package:diary/components/pixietext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diary/services/entryblock.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Box<EntryBlockDetails> _entryDetails;
  late List<EntryBlockDetails> entryBlocks;
  late User? user = null;

  late Box<int> _idTracker;
  late int currentID;
  int numba = 69;

  _HomeState() {
    print("initialzing hive");
    _initializeHive();
    _initializeIdTracker();
    user = FirebaseAuth.instance.currentUser;
  }
  

  Future<void> _initializeIdTracker() async {
    _idTracker = Hive.box<int>('idtracker');
    if(_idTracker.get(0) == null){
      await _idTracker.put(0, 0);
      currentID = 0;
    }
    else{
      currentID = _idTracker.get(0) as int;
    }
    //_idTracker.close();
    //_idTracker.clear();

  }

  Future<void> _initializeHive() async {
    _entryDetails = Hive.box<EntryBlockDetails>('entrydetails');
    Iterable<EntryBlockDetails> allEntries = _entryDetails.values;
    entryBlocks = allEntries.toList();

    print("entryBlocks initalized");
    print(entryBlocks.length);
  }

  void deleteItem(int id) {
    setState(() {
      id == -1 ? print("invalid id") : _entryDetails.delete(id);
      _initializeHive();
    });
  }

  void updateChange(bool changed){
    if(changed){
      setState(() {
        _initializeHive();
      });
    }
  }

  Future<void> _showInputDialog(BuildContext context) async {
    String newTitle = '';
    String newSubTitle = '';
    String content = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentTextStyle: TextStyle(color: Colors.white),
          backgroundColor: Colors.grey[900],
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: SizedBox(height: 0,),
          
          content: TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              newTitle = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter a title',
              hintStyle: TextStyle(color: Colors.grey.shade400)
            ),
          ),


          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white),),
            ),


            TextButton(
              onPressed: (){
                print('User input: $newTitle');
                setState(() {
                  currentID += 1;
                  //EntryBlock instance = EntryBlock(title: newTitle, subtitle: newSubTitle, id: 1,);
                  print("going to create instance");
                  EntryBlockDetails instance = EntryBlockDetails(id: currentID, title: newTitle, subtitle: currentID.toString());
                  print("going to create instanceblock");
                  EntryBlock instanceblock = EntryBlock(parentContext: context, instance: instance, deleteItemCallback: deleteItem, updateChange: updateChange,);
                  
                  entryBlocks.add(instance);
                  _entryDetails.put(currentID, instance);
                  _idTracker.put(0, currentID);
                });
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.white),),
            ),
          ],

        
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(user: user, updateChange: updateChange,),
      body: HomeBody(entryBlocks: entryBlocks, deleteItem: deleteItem, updateChange: updateChange,),
            floatingActionButton: FloatingActionButton(onPressed: (){
              setState(() {
                _showInputDialog(context);
              });
            },
            child: const Icon(Icons.add),
            backgroundColor: Colors.grey[200]),
            
    );
  }
}


class HomeAppBar extends StatefulWidget implements PreferredSizeWidget{
  final User? user;
  final void Function(bool) updateChange;

  const HomeAppBar({super.key, required this.user, required this.updateChange});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(color: Colors.white),
      title: Center(
        child: Row(
          children: <Widget>[
            const Icon(Icons.book, size: 25),
            const SizedBox(width: 10,),
            const Expanded(child: Text("Pixie", style: TextStyle(fontSize: 25,),)),
            const Icon(Icons.search),
            const SizedBox(width: 10,),
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(widget.user?.photoURL ?? "https://i.stack.imgur.com/l60Hf.png")
            ),
            IconButton(onPressed: () {
              Navigator.pushNamed(context, '/setting');
              /*dynamic result = await Navigator.pushNamed(context, '/setting');
              if(result){
                print("update changed");
                widget.updateChange(true);
              }*/
            }, icon: const Icon(Icons.settings), color: Colors.white,),
          ],
        ),
      ),
    );
  }
}

class HomeBody extends StatefulWidget {
  final List entryBlocks;
  final void Function(int) deleteItem;
  final void Function(bool) updateChange;

  const HomeBody({Key? key, required this.entryBlocks, required this.deleteItem, required this.updateChange}) : super(key: key);

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    try{
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 28, 28, 28), Color.fromARGB(255, 18, 18, 18)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
          )
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: (widget.entryBlocks.isNotEmpty ? 
        ListView.builder(
          itemCount: widget.entryBlocks.length,
          itemBuilder: (context, index){
            print("currently in itembuilder");
            return EntryBlock(parentContext: context, instance: widget.entryBlocks[index], deleteItemCallback: widget.deleteItem, updateChange: widget.updateChange,);  
          },
          padding: const EdgeInsets.symmetric(horizontal: 10),  
        ) : 
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Pixie(),
                const Text("Start out by writing a new memory",
                    style: TextStyle(color: Colors.white, fontSize: 20),  
                ),
                const SizedBox(height: 100,)
              ],
            )
          )
        )
      );
    }
    catch (e) {
      if (e is RangeError) {
        print('Caught a RangeError(Empty app): $e');
      } 
      else {
        print('An error occurred: $e');
      }

      return Container();
    };
  }
}