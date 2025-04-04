import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatiel/models/amenity.dart'; // Assurez-vous que ce chemin est correct

const Map<String, Map<String, String>> frenchRoomData = {
  'standard': {
    'name': 'Chambre Standard',
    'description': 'Une chambre confortable avec équipements de base',
  },
  'deluxe': {
    'name': 'Chambre Deluxe',
    'description': 'Une chambre spacieuse avec des équipements améliorés',
  },
  'suite': {
    'name': 'Suite',
    'description': 'Une suite luxueuse avec espace de vie séparé',
  },
  'executive': {
    'name': 'Chambre Exécutive',
    'description': 'Chambre premium avec privilèges exécutifs',
  },
  'family': {
    'name': 'Chambre Familiale',
    'description': 'Espace spacieux idéal pour les familles',
  },
  'presidential': {
    'name': 'Suite Présidentielle',
    'description': 'Le summum du luxe et du confort',
  },
  'honeymoon': {
    'name': 'Suite Luna de Miel',
    'description': 'Un cadre romantique pour couples',
  },
  'business': {
    'name': 'Chambre Affaires',
    'description': 'Conçue pour les voyageurs professionnels',
  },
};

// Fonction pour générer et télécharger des chambres pour un hôtel unique
Future<void> generateAndUploadHotelRoomsForHotel(
    String hotelId, Map<String, dynamic> hotelData) async {
  final firestore = FirebaseFirestore.instance;
  final random = Random();

  final configs =
      _getDefaultRoomConfig(hotelData); // Obtenir les configurations de chambre

  for (final config in configs) {
    final roomType = config['type'] as String;
    final basePrice = config['basePrice'] as int;
    final amenities = List<String>.from(config['amenities'] as List);

    // Ajouter 1-3 équipements supplémentaires aléatoires
    final allAmenities = AmenityIcons.allAmenityLabels;
    final additionalAmenities = allAmenities
        .where((a) => !amenities.contains(a.toLowerCase()))
        .toList()
      ..shuffle(random);

    amenities.addAll(additionalAmenities.take(1 + random.nextInt(2)));

    // Créer des données de chambre avec des noms français
    final roomData = {
      'hotelId': hotelId,
      'name': frenchRoomData[roomType]!['name']!,
      'description': frenchRoomData[roomType]!['description']!,
      'capacity': _getCapacityForRoomType(roomType, random),
      'pricePerNight': _calculateFinalPrice(basePrice, random),
      'images': hotelData['images'] ??
          [], // Utiliser les images de l'hôtel, ou une liste vide si null
      'amenities': amenities,
      'availability': {
        'isAvailable': true, // Toutes les chambres sont disponibles par défaut
        'nextAvailableDate': null,
      },
      'rating': 0, // Note initiale définie sur 0
    };

    await firestore.collection('rooms').add(roomData);
  }
}

List<Map<String, dynamic>> _getDefaultRoomConfig(Map<String, dynamic> hotel) {
  final rating = (hotel['ratings']['average'] as double?) ?? 3.0;

  if (rating >= 4.5) {
    return [
      {
        'type': 'suite',
        'basePrice': 50000,
        'amenities': ['wifi', 'ac', 'minibar', 'tv', 'safe']
      },
      {
        'type': 'executive',
        'basePrice': 35000,
        'amenities': ['wifi', 'ac', 'minibar', 'tv']
      },
      {
        'type': 'deluxe',
        'basePrice': 25000,
        'amenities': ['wifi', 'ac', 'tv']
      },
    ];
  } else if (rating >= 4.0) {
    return [
      {
        'type': 'suite',
        'basePrice': 35000,
        'amenities': ['wifi', 'ac', 'tv', 'minibar']
      },
      {
        'type': 'deluxe',
        'basePrice': 25000,
        'amenities': ['wifi', 'ac', 'tv']
      },
      {
        'type': 'standard',
        'basePrice': 15000,
        'amenities': ['wifi', 'ac']
      },
    ];
  } else {
    return [
      {
        'type': 'deluxe',
        'basePrice': 20000,
        'amenities': ['wifi', 'ac', 'tv']
      },
      {
        'type': 'standard',
        'basePrice': 12000,
        'amenities': ['wifi', 'ac']
      },
    ];
  }
}

int _getCapacityForRoomType(String type, Random random) {
  switch (type) {
    case 'presidential':
    case 'suite':
      return 2 + random.nextInt(2); // 2-3
    case 'family':
      return 4 + random.nextInt(3); // 4-6
    case 'honeymoon':
      return 2;
    default:
      return 1 + random.nextInt(2); // 1-2
  }
}

double _calculateFinalPrice(int basePrice, Random random) {
  // Ajouter une variation aléatoire (10-30%)
  final variation = 1.0 + (random.nextDouble() * 0.2 + 0.1);
  return (basePrice * variation).roundToDouble();
}

Future<void> initializeHotelRooms() async {
  try {
    final hotelsData = [
      {
        "id": "zrH68k8YOTSTrL9U2gBiPtP4pz92",
        "email": "contact@el-aurassi.com",
        "hotelName": "Hôtel El Aurassi",
        "location": "ALG",
        "ratings": {"average": 4.5, "count": 1247},
        "images": [
          "https://example.com/elaurassi1.jpg",
          "https://example.com/elaurassi2.jpg"
        ],
        "totalRooms": 295,
        "description":
            "Hôtel 5 étoiles avec vue imprenable sur la baie d'Alger. Piscine, spa et restaurants gastronomiques.",
        "mapLink": "https://goo.gl/maps/XYZ123",
        "contactInfo": "+213 21 23 45 67",
        "searchKeywords": ["luxe", "baie d'Alger", "5 étoiles"]
      },
      {
        "id": "fyLASm25imNcjnkh3dT18BLq2vI3",
        "email": "reservation@mazafran-oran.com",
        "hotelName": "Mazafran Oran",
        "location": "ORN",
        "ratings": {"average": 4.2, "count": 892},
        "images": ["https://example.com/mazafran1.jpg"],
        "totalRooms": 120,
        "description":
            "Hôtel 4 étoiles au cœur d'Oran, à proximité de la plage et du centre-ville.",
        "contactInfo": "+213 41 34 56 78",
        "searchKeywords": ["plage", "centre-ville", "Oran"]
      },
      {
        "id": "VcwsgzfcZ4bsAsf5NgSeCVRRRsi1",
        "email": "info@hotel-tlemcen.com",
        "hotelName": "Hôtel Renaissance Tlemcen",
        "location": "TLM",
        "ratings": {"average": 4.7, "count": 653},
        "images": [
          "https://example.com/tlemcen1.jpg",
          "https://example.com/tlemcen2.jpg"
        ],
        "totalRooms": 180,
        "description":
            "Établissement 5 étoiles niché dans les collines de Tlemcen, avec vue sur les montagnes.",
        "mapLink": "https://goo.gl/maps/ABC456",
        "contactInfo": "+213 43 45 67 89",
        "searchKeywords": ["montagne", "nature", "Tlemcen"]
      },
      {
        "id": "n9CT5Qlag9Xy99bW7Kiafo0CsOf1",
        "email": "contact@hotel-sahara.com",
        "hotelName": "Hôtel Le Sahara",
        "location": "BSK",
        "ratings": {"average": 3.9, "count": 421},
        "images": ["https://example.com/sahara1.jpg"],
        "totalRooms": 85,
        "description":
            "Hôtel 3 étoiles typique de Biskra, porte d'entrée du Sahara algérien.",
        "contactInfo": "+213 33 23 45 67",
        "searchKeywords": ["désert", "Sahara", "Biskra"]
      },
      {
        "id": "hv7jsmE5WnVDq3hER99QZTagLnx1",
        "email": "accueil@hotel-bejaia.com",
        "hotelName": "Hôtel La Corniche Béjaïa",
        "location": "BJA",
        "ratings": {"average": 4.1, "count": 587},
        "images": [
          "https://example.com/bejaia1.jpg",
          "https://example.com/bejaia2.jpg"
        ],
        "totalRooms": 110,
        "description":
            "Hôtel face à la mer avec une vue exceptionnelle sur la baie de Béjaïa.",
        "contactInfo": "+213 34 56 78 90",
        "searchKeywords": ["mer", "baie", "Béjaïa"]
      },
      {
        "id": "MzME7i3a77aoYvlHQrKAKMKrFep2",
        "email": "reservation@hotel-benitala.com",
        "hotelName": "Hôtel Beni Tala",
        "location": "SBA",
        "ratings": {"average": 4.3, "count": 421},
        "images": [
          "https://example.com/benitala1.jpg",
          "https://example.com/benitala2.jpg"
        ],
        "totalRooms": 72,
        "description":
            "Hôtel de charme situé dans un quartier résidentiel calme, avec jardin paysager.",
        "mapLink": "https://goo.gl/maps/DEF789",
        "contactInfo": "+213 48 78 90 12",
        "searchKeywords": ["quartier calme", "jardin", "charme"]
      },
      {
        "id": "FUNz0sWE67UNjs7JiqOWPNBtDid2",
        "email": "contact@hotel-eden.com",
        "hotelName": "Hôtel Eden",
        "location": "SBA",
        "ratings": {"average": 3.8, "count": 387},
        "images": [
          "https://example.com/eden1.jpg",
          "https://example.com/eden2.jpg"
        ],
        "totalRooms": 95,
        "description":
            "Hôtel moderne avec salle de conférence et espace bien-être, idéal pour séjours professionnels.",
        "contactInfo": "+213 48 89 01 23",
        "searchKeywords": ["conférence", "bien-être", "professionnel"]
      }
    ];

    for (final hotelData in hotelsData) {
      final hotelId = hotelData['id'] as String;
      await generateAndUploadHotelRoomsForHotel(hotelId, hotelData);
    }
    print(
        'Données de chambre françaises générées et téléchargées avec succès pour tous les hôtels.');
  } catch (e) {
    print('Erreur lors de l\'initialisation des chambres d\'hôtel : $e');
  }
}
