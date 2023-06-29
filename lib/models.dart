class Celebrity {
  String name;
  String desc;
  String imagePath;

  Celebrity({required this.name, required this.desc, required this.imagePath});

  factory Celebrity.fromJson(Map<String, dynamic> json) => Celebrity(
        name: json["name"],
        desc: json["known_for_department"],
        imagePath: json['profile_path'],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "desc": desc,
        "imagePath": imagePath,
      };
}
