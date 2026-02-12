// lib/core/constants/initial_data.dart

class InitialResidentData {
  final int id; // ID Appartement correspond souvent à ID table locale simplifiée
  final String name;
  final int floor;
  final int aptNumber;
  final String role;

  const InitialResidentData(this.id, this.name, this.floor, this.aptNumber, this.role);
}

const List<InitialResidentData> kInitialResidents = [
  // Étage 1
  InitialResidentData(1, "Ayazi Adnan", 1, 1, 'resident'),
  InitialResidentData(2, "Dehbi Fatima", 1, 2, 'resident'),
  InitialResidentData(3, "Mouktadi Nora", 1, 3, 'resident'),
  InitialResidentData(4, "Jalila Annan", 1, 4, 'resident'),
  InitialResidentData(5, "Yahya Sbai", 1, 5, 'resident'),

  // Étage 2
  InitialResidentData(6, "Boukherssa Yasmine", 2, 6, 'resident'),
  InitialResidentData(7, "Liassini Jalal", 2, 7, 'resident'),
  InitialResidentData(8, "Kenbouchi Abdelati", 2, 8, 'syndic'), // Rôle SYNDIC
  InitialResidentData(9, "Marwa Sbaili", 2, 9, 'resident'),
  InitialResidentData(10, "Halil Bessam", 2, 10, 'resident'),

  // Étage 3
  InitialResidentData(11, "Rahil Adil", 3, 11, 'resident'),
  InitialResidentData(12, "Arif Mohsine", 3, 12, 'resident'),
  InitialResidentData(13, "Oualad Asmaa", 3, 13, 'resident'),
  InitialResidentData(14, "Fidar Naoual", 3, 14, 'resident'),
  InitialResidentData(15, "Es-Saidi Kawtar", 3, 15, 'resident'),
];

const kAdjointName = "Badr Daby";
const kMonthlyFee = 250;
