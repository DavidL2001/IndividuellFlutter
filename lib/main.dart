import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        backgroundColor:  Color(0xFFa29B94), //rubrik Färgen från figman 
        title: Image.asset('images/sverigesradio.png'), //lagt till bild istället för rubrik text
      ),
      body: const RadioEpList(),
    ),
  ));
}


class RadioEpisode {
  final String title;
  final String description;
  final DateTime startTime;
  final String imageUrl;
  //final String endTime;

  RadioEpisode({
    required this.title,
    required this.description,
    required this.startTime,
    required this.imageUrl,
    //required this.endTime
  });
}

class RadioEpList extends StatefulWidget {
  const RadioEpList({super.key});

  @override
  _RadioEpListState createState() => _RadioEpListState();
  
}

class _RadioEpListState extends State<RadioEpList> {
  List<RadioEpisode> episodes = [];


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      String url = "https://api.sr.se/api/v2/scheduledepisodes?channelid=164&format=json";

    final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)); //ändrar special tecknen till dem korrekta åäö
        final schedule = data['schedule'];

        setState(() {
          episodes = schedule.map<RadioEpisode>((episode) {
            DateTime startTime = DateTime.fromMillisecondsSinceEpoch(

              int.parse(episode['starttimeutc'].split("(")[1].split(")")[0]), //ändrar starttime info till korrekta klockslag
            ); 

            return RadioEpisode(
              title: episode['title'],
              description: episode['description'],
              startTime: startTime,
              imageUrl: episode['imageurl'],
              //endTime: episode['endTime']
            );
          }).toList();
        });
      } 
    } catch (e) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEDECEB), //Färgen från figman
      child: ListView.builder(
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(episodes[index].imageUrl),
            title: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD7D4D1), 
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(6),

              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episodes[index].title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            
                          ),
                          Text(episodes[index].description),
                        ],
                      ),
                    ),
                    Text(
                      '${episodes[index].startTime.hour.toString().padLeft(2, '0')}:${episodes[index].startTime.minute.toString().padLeft(2, '0')}',
                      //inkluderar tiden o ändrar tiden till timme o minut
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
