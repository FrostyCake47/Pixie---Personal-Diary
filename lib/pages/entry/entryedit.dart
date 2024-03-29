import 'package:diary/services/entryblock.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EntryEdit extends StatefulWidget {
  const EntryEdit({super.key});

  @override
  State<EntryEdit> createState() => _EntryEditState();
}

class _EntryEditState extends State<EntryEdit> {
  late Map? data;
  late EntryBlockDetails instance;
  late Box<EntryBlockDetails> _entryDetails;

  Future<void> _initializeHive() async {
    _entryDetails = Hive.box<EntryBlockDetails>('entrydetails');
    print("entryBlocks initalized");
  }

  void createInstance(){
    _initializeHive();
    instance = _entryDetails.get(data?['id']) ?? EntryBlockDetails(id: -1, title: "title", subtitle: "subtitle");
  }

  void saveEdit(String newTitle){
    Navigator.of(context).pop();
    print(newTitle);
    //later i save this to db
  }

@override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)?.settings.arguments as Map?;
    createInstance();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () async {
                instance.subtitle = instance.content.length > 80 ? instance.content.substring(0, 80) : instance.content;
                _entryDetails.put(instance.id, instance);
                print("popping back after editing 48 entryedit " + instance.title);
                Navigator.pop(context, {'id':instance.id});
              },
              icon: const Icon(Icons.check),
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: EntryEditBody(
        instance: instance,
        onTitleChanged: (newTitle) {
          print("instance.title changed line 62 entryedit");
          instance.title = newTitle;
        },
        onContentChanged: (newContent){
          instance.content = newContent;
        },

      ),
    );
  }
}

class EntryEditBody extends StatelessWidget {
  final EntryBlockDetails instance;
  final Function(String) onTitleChanged;
  final Function(String) onContentChanged;

  EntryEditBody({Key? key, required this.instance, required this.onTitleChanged, required this.onContentChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EntryEditTime(instance: instance),
            const SizedBox(height: 10,),
            EntryEditTitle(instance: instance, onTitleChanged: onTitleChanged),
            const SizedBox(height: 10,),
            EntryEditContent(instance: instance, onContentChanged: onContentChanged)
          ],
        ),
      ),
    );
  }
}

class EntryEditTitle extends StatelessWidget {
  final EntryBlockDetails instance;
  final Function(String) onTitleChanged;

  EntryEditTitle({Key? key, required this.instance, required this.onTitleChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: instance.title),
      maxLines: null,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: const TextStyle(
        fontSize: 30,
        color: Colors.white,
      ),
      onChanged: (value) {
        // Call the callback function when the title changes
        onTitleChanged(value);
      },
    );
  }
}

class EntryEditContent extends StatelessWidget {
  final EntryBlockDetails instance;
  final Function(String) onContentChanged;

  const EntryEditContent({super.key, required this.instance, required this.onContentChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: TextField(
        controller: TextEditingController(text: instance.content == "      " ? "" : instance.content),

        onChanged: (value) {
          onContentChanged(value);
        },      
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: "Dear diary..",
          hintStyle: TextStyle(color: Colors.grey)
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(fontSize: 18.0, color: Colors.white),
        textAlign: TextAlign.left,
      ),
    );
  }
}


class EntryEditTime extends StatelessWidget {
  const EntryEditTime({
    super.key,
    required this.instance,
  });

  final EntryBlockDetails instance;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(instance.day + " · "  + instance.date + "  |  " +  instance.time ,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey
          ),
        ),

        Text("#${instance.id}",
        style: const TextStyle(
            fontSize: 15,
            color: Colors.grey
          ),
        )
      ],
    );
  }
}