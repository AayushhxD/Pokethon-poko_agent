import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../models/pokeagent.dart';
import '../services/wallet_service.dart';
import '../data/pokemon_data.dart';

class MintScreen extends StatefulWidget {
  const MintScreen({super.key});

  @override
  State<MintScreen> createState() => _MintScreenState();
}

class _MintScreenState extends State<MintScreen> {
  String? _selectedType;
  String? _selectedPokemon;
  bool _isMinting = false;
  String? _customPokemonName;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final Map<String, List<String>> _pokemonByType = {
    'Fire': [
      'Charizard',
      'Blaziken',
      'Arcanine',
      'Typhlosion',
      'Infernape',
      'Flareon',
      'Rapidash',
      'Ninetales',
      'Magmar',
      'Houndoom',
      'Torkoal',
      'Camerupt',
      'Salamence',
      'Entei',
      'Ho-Oh',
    ],
    'Water': [
      'Blastoise',
      'Swampert',
      'Gyarados',
      'Feraligatr',
      'Empoleon',
      'Kingdra',
      'Milotic',
      'Ludicolo',
      'Swalot',
      'Quagsire',
      'Pelipper',
      'Crawdaunt',
      'Whiscash',
      'Relicanth',
      'Huntail',
    ],
    'Electric': [
      'Pikachu',
      'Raichu',
      'Electivire',
      'Magnezone',
      'Electabuzz',
      'Zapdos',
      'Manectric',
      'Electrode',
      'Ampharos',
      'Jolteon',
      'Luxray',
      'Rotom',
      'Elekid',
      'Mareep',
      'Pichu',
    ],
    'Psychic': [
      'Mewtwo',
      'Gardevoir',
      'Gallade',
      'Metagross',
      'Alakazam',
      'Espeon',
      'Mew',
      'Celebi',
      'Jirachi',
      'Deoxys',
      'Bronzor',
      'Chimecho',
      'Wobbuffet',
      'Slowking',
      'Xatu',
    ],
    'Grass': [
      'Venusaur',
      'Sceptile',
      'Torterra',
      'Turtwig',
      'Snivy',
      'Leafeon',
      'Chikorita',
      'Meganium',
      'Treecko',
      'Grovyle',
      'Tropius',
      'Carnivine',
      'Budew',
      'Roserade',
      'Tangela',
    ],
    'Ice': [
      'Articuno',
      'Glalie',
      'Weavile',
      'Glaceon',
      'Lapras',
      'Mamoswine',
      'Froslass',
      'Sneasel',
      'Snorunt',
      'Glalie',
      'Spheal',
      'Sealeo',
      'Walrein',
      'Regice',
      'Snorlax',
    ],
  };

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: $e',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showCustomPokemonDialog() {
    final TextEditingController customNameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Create Custom Pokémon',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customNameController,
                  style: GoogleFonts.poppins(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Enter Pokémon name...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF3861FB),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedImage != null)
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: Text(
                    'Pick Image',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3861FB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (customNameController.text.isNotEmpty) {
                    setState(() {
                      _customPokemonName = customNameController.text;
                      _selectedPokemon = customNameController.text;
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3861FB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _mintAgent() async {
    if (_selectedPokemon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a Pokémon',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final walletService = Provider.of<WalletService>(context, listen: false);
    if (!walletService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please connect your wallet first',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isMinting = true;
    });

    try {
      // Create agent
      final agent = PokeAgent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _selectedPokemon!,
        type: _selectedType!,
        imageUrl:
            _selectedImage != null
                ? _selectedImage!.path
                : PokemonData.getPngUrl(_selectedPokemon!),
        personality: 'Friendly',
      );

      // In production:
      // 1. Generate AI image using Stable Diffusion
      // 2. Upload image to IPFS
      // 3. Upload metadata to IPFS
      // 4. Mint NFT on Base blockchain

      // For demo, just create the agent locally
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Agent minted successfully!',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context, agent);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to mint: $e',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMinting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:
            _selectedType != null
                ? IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                      _selectedPokemon = null;
                      _customPokemonName = null;
                      _selectedImage = null;
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 20,
                  ),
                )
                : IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
        title: Text(
          _selectedType != null
              ? 'Select $_selectedType Pokémon'
              : 'Mint PokéAgent',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Character Image at top
                    Center(
                      child: FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Image.asset(
                          'assets/images/mint.png',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Type/Pokemon Selection
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedType == null
                                ? 'Select Type'
                                : 'Select Pokémon',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedType == null)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: AppConstants.agentTypes.length,
                              itemBuilder: (context, index) {
                                final type = AppConstants.agentTypes[index];
                                final typeColor = AppTheme.getTypeColor(type);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedType = type;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _getTypeIcon(type),
                                          size: 36,
                                          color: typeColor,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          type,
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount:
                                  _pokemonByType[_selectedType]!.length + 1,
                              itemBuilder: (context, index) {
                                if (index ==
                                    _pokemonByType[_selectedType]!.length) {
                                  // Custom Pokémon option
                                  final isSelected =
                                      _selectedPokemon == _customPokemonName;
                                  final typeColor = AppTheme.getTypeColor(
                                    _selectedType!,
                                  );

                                  return GestureDetector(
                                    onTap: _showCustomPokemonDialog,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? typeColor.withOpacity(0.1)
                                                : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? typeColor
                                                  : Colors.grey.shade300,
                                          width: isSelected ? 3 : 1.5,
                                        ),
                                        boxShadow:
                                            isSelected
                                                ? [
                                                  BoxShadow(
                                                    color: typeColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 12,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                                : null,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.grey.shade200,
                                            ),
                                            child: Icon(
                                              Icons.add_a_photo,
                                              size: 30,
                                              color: typeColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Custom',
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final pokemon =
                                    _pokemonByType[_selectedType]![index];
                                final isSelected = _selectedPokemon == pokemon;
                                final typeColor = AppTheme.getTypeColor(
                                  _selectedType!,
                                );

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedPokemon = pokemon;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? typeColor.withOpacity(0.1)
                                              : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? typeColor
                                                : Colors.grey.shade300,
                                        width: isSelected ? 3 : 1.5,
                                      ),
                                      boxShadow:
                                          isSelected
                                              ? [
                                                BoxShadow(
                                                  color: typeColor.withOpacity(
                                                    0.3,
                                                  ),
                                                  blurRadius: 12,
                                                  spreadRadius: 0,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: CachedNetworkImage(
                                            key: UniqueKey(),
                                            imageUrl: PokemonData.getPngUrl(
                                              pokemon,
                                            ),
                                            placeholder:
                                                (
                                                  context,
                                                  url,
                                                ) => CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(typeColor),
                                                  strokeWidth: 2,
                                                ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                  Icons.catching_pokemon,
                                                  color: typeColor,
                                                  size: 32,
                                                ),
                                            fit: BoxFit.cover,
                                            memCacheWidth: 60,
                                            memCacheHeight: 60,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          pokemon,
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Info Card
                    if (_selectedPokemon != null)
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.getTypeColor(
                              _selectedType!,
                            ).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.getTypeColor(
                                _selectedType!,
                              ).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child:
                                        _selectedImage != null
                                            ? Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                            )
                                            : CachedNetworkImage(
                                              key: UniqueKey(),
                                              imageUrl: PokemonData.getPngUrl(
                                                _selectedPokemon!,
                                              ),
                                              placeholder:
                                                  (
                                                    context,
                                                    url,
                                                  ) => CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          AppTheme.getTypeColor(
                                                            _selectedType!,
                                                          ),
                                                        ),
                                                    strokeWidth: 2,
                                                  ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                    Icons.catching_pokemon,
                                                    color:
                                                        AppTheme.getTypeColor(
                                                          _selectedType!,
                                                        ),
                                                    size: 24,
                                                  ),
                                              fit: BoxFit.cover,
                                              memCacheWidth: 50,
                                              memCacheHeight: 50,
                                            ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Pokémon: $_selectedPokemon',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Type: $_selectedType • ${_getTypeDescription(_selectedType!)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Mint Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isMinting ? null : _mintAgent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF3861FB),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isMinting
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  'Minting...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  'Mint Agent',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'water':
        return Icons.water_drop;
      case 'electric':
        return Icons.flash_on;
      case 'psychic':
        return Icons.psychology;
      case 'grass':
        return Icons.grass;
      case 'ice':
        return Icons.ac_unit;
      default:
        return Icons.catching_pokemon;
    }
  }

  String _getTypeDescription(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return 'Fierce and passionate. Excels in aggressive battles with powerful fire-based attacks.';
      case 'water':
        return 'Calm and adaptable. Great defensive capabilities with strong water manipulation.';
      case 'electric':
        return 'Fast and energetic. Lightning-quick attacks that can paralyze opponents.';
      case 'psychic':
        return 'Intelligent and mysterious. Master of mind games with telekinetic powers.';
      case 'grass':
        return 'Natural and resilient. Strong regenerative abilities and nature control.';
      case 'ice':
        return 'Cool and strategic. Freezing battlefield control with ice-based powers.';
      default:
        return 'A unique and powerful agent with special abilities.';
    }
  }
}
