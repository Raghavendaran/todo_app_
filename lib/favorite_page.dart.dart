import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff000000),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/yoga.jpg'), // Updated asset
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text(
                'Yoga',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  backgroundColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gym.jpg'), // Updated asset
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text(
                'Gym',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  backgroundColor: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
