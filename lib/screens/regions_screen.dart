import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

class RegionsScreen extends StatelessWidget {
  const RegionsScreen({super.key});

  final List<Map<String, dynamic>> regions = const [
    {
      'name': 'Kanto',
      'color': Color(0xFF3861FB),
      'description': 'The original region',
      'types': ['Fire', 'Water', 'Electric', 'Grass'],
    },
    {
      'name': 'Johto',
      'color': Color(0xFFCD3131),
      'description': 'The second generation',
      'types': ['Dark', 'Steel', 'Bug', 'Dragon'],
    },
    {
      'name': 'Hoenn',
      'color': Color(0xFF4CAF50),
      'description': 'The third generation',
      'types': ['Normal', 'Flying', 'Poison', 'Ground'],
    },
    {
      'name': 'Sinnoh',
      'color': Color(0xFFFF9800),
      'description': 'The fourth generation',
      'types': ['Fighting', 'Psychic', 'Rock', 'Ice'],
    },
    {
      'name': 'Unova',
      'color': Color(0xFF9C27B0),
      'description': 'The fifth generation',
      'types': ['Ghost', 'Fire', 'Water', 'Electric'],
    },
    {
      'name': 'Kalos',
      'color': Color(0xFFE91E63),
      'description': 'The sixth generation',
      'types': ['Fairy', 'Grass', 'Fire', 'Water'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Pokémon Regions',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: regions.length,
          itemBuilder: (context, index) {
            final region = regions[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: region['color'].withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: region['color'].withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // TODO: Navigate to region-specific agents
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: region['color'].withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: region['color'],
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            region['name'],
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            region['description'],
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
