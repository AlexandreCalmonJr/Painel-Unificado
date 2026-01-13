class Command {

  Command({
    required this.id,
    required this.name,
    required this.command,
    required this.description,
    required this.requiresAdmin,
    required this.supportedOS,
  });

  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      command: json['command'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requiresAdmin: json['requiresAdmin'] as bool? ?? false,
      supportedOS: List<String>.from(json['supportedOS'] as List? ?? []),
    );
  }
  final String id;
  final String name;
  final String command;
  final String description;
  final bool requiresAdmin;
  final List<String> supportedOS;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'command': command,
      'description': description,
      'requiresAdmin': requiresAdmin,
      'supportedOS': supportedOS,
    };
  }
}
