import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

// import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

var CurrentLatitude;
var CurrentLongitude;
List MarkerTitle = [];
List MarkerLat = [];
List MarkerLong = [];
List Latitude = [];
List Longitude = [];
int i = 0;
String key = 'YOUR_API_KEY';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kGoogle = CameraPosition(
    target: LatLng(26.8467, 80.9462),
    zoom: 14,
  );

  final List<Marker> _markers = <Marker>[];

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }

  Future? data;

  @override
  void initState() {
    super.initState();
    data = function(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=toilet&location=$CurrentLatitude,$CurrentLongitude&radius=500&type=toilet&key=$key");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NearBy Public Toilet',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade900,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 370,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              child: GoogleMap(
                initialCameraPosition: _kGoogle,
                markers: Set<Marker>.of(_markers),
                mapType: MapType.normal,
                myLocationEnabled: true,
                compassEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 500,
              child: FutureBuilder(
                future: data,
                builder: (context, AsyncSnapshot value1) {
                  if (value1.hasData) {
                    return CreatingList(value1.data, context);
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.grey.shade900,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getUserCurrentLocation().then(
            (value) async {
              for (i = 0; i < MarkerLong.length; i++) {
                _markers.add(
                  Marker(
                    markerId: MarkerId("$i"),
                    position: LatLng(MarkerLat[i], MarkerLong[i]),
                    infoWindow: InfoWindow(
                      title: MarkerTitle[i],
                    ),
                  ),
                );
              }
              CameraPosition cameraPosition = CameraPosition(
                target: LatLng(value.latitude, value.longitude),
                zoom: 14.5,
              );
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition));
              setState(() {});
            },
          );
          // Fluttertoast.showToast(
          //     msg: 'Successfully Fetched', backgroundColor: Colors.green);
        },
        child: Icon(Icons.my_location),
        backgroundColor: Colors.grey.shade600,
      ),
    );
  }

  //Creating a function to get Json body
  Future? function(String api) async {
    var location = await Geolocator.getCurrentPosition();
    CurrentLatitude = location.latitude;
    CurrentLongitude = location.longitude;
    Response value1 = await get(Uri.parse(api));
    if (value1.statusCode == 200) {
      print(value1.body);
      var value2 = jsonDecode(value1.body);
      print(value2);
      return (value2["results"]);
    } else {
      return value1.statusCode;
    }
  }

  Widget CreatingList(List data, BuildContext context) {
    return Container(
      child: InkWell(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, int index) {
            MarkerLat.add(data[index]["geometry"]["location"]["lat"]);
            MarkerLong.add(data[index]["geometry"]["location"]["lng"]);
            MarkerTitle.add(data[index]["name"]);
            i++;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () async {
                      await launchUrl(Uri.parse(
                          'google.navigation:q=${(data[index]["geometry"]["location"]["lat"])},${(data[index]["geometry"]["location"]["lng"])}&key=$key'));
                    },
                    child: Card(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        child: ListTile(
                          title: Text(
                            data[index]["business_status"],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Name: ",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    (data[index]["name"]),
                                    style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const Text("Address: ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  Expanded(
                                      child: Text((data[index]["vicinity"]),
                                          style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontSize: 15))),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const Text("Rating: ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  Text((data[index]["rating"].toString()),
                                      style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 15))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
