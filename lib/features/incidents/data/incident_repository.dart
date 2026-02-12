class IncidentRepository {
  // Mock function to demonstrate filtering logic
  Future<List<Map<String, dynamic>>> getIncidents({required String userRole}) async {
    // In a real app, this would be a Drift or Supabase query
    // SELECT * FROM incidents WHERE ...

    final allIncidents = [
      {'id': 1, 'type': 'LEAK', 'description': 'Fuite eau cuisine', 'target_role': 'SYNDIC'},
      {'id': 2, 'type': 'COMPLAINT_AGAINST_STAFF', 'description': 'Concierge absent', 'target_role': 'SYNDIC'},
      {'id': 3, 'type': 'LIGHT_BULB', 'description': 'Ampoule grillée Hall', 'target_role': 'CONCIERGE'},
    ];

    if (userRole == 'CONCIERGE') {
      return allIncidents.where((incident) {
        // Concierge sees incidents assigned to them OR general technical issues
        // BUT MUST NOT see complaints against staff
        final type = incident['type'] as String;
        return type != 'COMPLAINT_AGAINST_STAFF';
      }).toList();
    }

    return allIncidents;
  }
}
