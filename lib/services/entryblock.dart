import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

//part 'entryblock.g.dart';

class EntryBlockDetails{
  late final int id;
  late final String title;
  late final String subtitle;
  late final String date;
  late final String time;
  late final String day;

  EntryBlockDetails({Key? key, required this.id, required this.title, required this.subtitle,});
}

class EntryBlock extends StatelessWidget {
  final EntryBlockDetails? instance;

  EntryBlock({Key? key, required this.instance}): super(key: key){
    DateTime now = DateTime.now();
    instance?.date = DateFormat('d MMM').format(now);
    instance?.time = DateFormat.jm().format(now).toString();
    instance?.day = DateFormat.E('en_US').format(now);
    print(instance?.day);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.grey[900],
      ),

      child: ListTile(
        title: Text(instance?.title ?? "title"),
        subtitle: Text(instance?.subtitle ?? "subtitle"),
        trailing: Text(instance?.date ?? "date"),
        tileColor: Colors.grey[400],

        onTap: () async {
          await Navigator.pushNamed(context, '/entry', arguments: {
            'title': instance?.title ?? "title", 
            'subtitle': instance?.subtitle ?? "subtitle", 
            'date': instance?.date ?? "date", 
            'time': instance?.time ?? "time",
            'day' : instance?.day ?? "day",
          });
        },
        
        titleTextStyle: const TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
        subtitleTextStyle: const TextStyle(
          color: Colors.grey,
        ),
        leadingAndTrailingTextStyle: const TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }
}


class EntryTitle extends StatefulWidget {
  final Map? data;
  const EntryTitle({Key? key, this.data}) : super(key: key);

  @override
  State<EntryTitle> createState() => _EntryTitleState();
}

class _EntryTitleState extends State<EntryTitle> {
  
  @override
  Widget build(BuildContext context) {
    return Text(widget.data?['title'],
      style: const TextStyle(
        fontSize: 30,
        color: Colors.white
      ),
    );
  }
}


class EntryDateTime extends StatefulWidget {
  final Map? data;
  const EntryDateTime({Key? key, this.data}) : super(key: key);

  @override
  State<EntryDateTime> createState() => _EntryDateTimeState();
}

class _EntryDateTimeState extends State<EntryDateTime> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.data?['day'] + " · "  + widget.data?['date'] + "  |  " +  widget.data?['time'],
      style: const TextStyle(
        fontSize: 15,
        color: Colors.grey
      ),
    );
  }
}


class WrittenContent extends StatefulWidget {
  final Map? data;

  const WrittenContent({Key? key, this.data}) : super(key: key);

  @override
  State<WrittenContent> createState() => _WrittenContentState();
}

class _WrittenContentState extends State<WrittenContent> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(widget.data?['content']));
  }
}