class Dosage {
  const Dosage({required this.name, required this.dose, this.container = 0});

  final String name;
  final int container;
  final int dose;

  factory Dosage.fromJson(Map<String, dynamic> data) {
    if (data case { 'name': String name, 'dose': int dose, 'container': int container}) {
      return Dosage(name: name, dose: dose, container: container);
    } else {
      throw FormatException('Invalid JSON: $data');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dose': dose,
      'container': container,
    };
  }
}