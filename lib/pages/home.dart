import 'package:flutter/material.dart';
import 'package:diary/services/entryblock.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /*List entryBlocks = [
    EntryBlock(title: "mwaa", subtitle: "lmao what?", id: 1,),
    EntryBlock(title: "idk lmao", subtitle: "what else to write here?", id: 2,),];
  */

  late Box<EntryBlockDetails> _entryDetails;
  late List<EntryBlockDetails> entryBlocks;

  late Box<int> _idTracker;
  late int currentID;
  int numba = 69;

  _HomeState() {
    print("initialzing hive");
    _initializeHive();
    _initializeIdTracker();
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
    //_idTracker.clear();

  }

  Future<void> _initializeHive() async {
    _entryDetails = Hive.box<EntryBlockDetails>('entrydetails');
    Iterable<EntryBlockDetails> allEntries = _entryDetails.values;
    entryBlocks = allEntries.toList();
    //_entryDetails.clear();
    print("entryBlocks initalized");
  }



  Future<void> _showInputDialog(BuildContext context) async {
    String newTitle = '';
    String newSubTitle = '';
    String content = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Title'),
          content: TextField(
            onChanged: (value) {
              newTitle = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter a title',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
                  EntryBlock instanceblock = EntryBlock(instance: instance);
                  
                  entryBlocks.add(instance);

                  _entryDetails.put(currentID, instance);
                  _idTracker.put(0, currentID);
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: HomeBody(entryBlocks: entryBlocks,),
            floatingActionButton: FloatingActionButton(onPressed: (){
              setState(() {
                _showInputDialog(context);
              });
            },
            child: const Icon(Icons.add),),   
    );
  }
}


class HomeAppBar extends StatelessWidget implements PreferredSizeWidget{
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(color: Colors.white),
      title: const Center(
        child: Row(
          children: <Widget>[
            Icon(Icons.book,),
            SizedBox(width: 10,),
            Expanded(child: Text("My Diary")),
            Icon(Icons.search),
            SizedBox(width: 10,),
            CircleAvatar(radius: 10, child: Image(
              image: AssetImage('assets/PaperPlanes1.jpg')),
              )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HomeBody extends StatefulWidget {
  final List entryBlocks;
  const HomeBody({Key? key, required this.entryBlocks}) : super(key: key);

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    try{
      return Container(
        child: ListView.builder(
          itemCount: widget.entryBlocks.length,
          itemBuilder: (context, index){
            print("currently in itembuilder");
            return EntryBlock(instance: widget.entryBlocks[index]);  
          },
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),  
        ),
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
