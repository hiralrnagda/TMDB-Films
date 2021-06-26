class Cast{
  final int id;
  final String character;
  final String name;
  final String img;

  Cast(
    this.id,
    this.character,
    this.img,
    this.name
  );

  Cast.fromJson(Map<String, dynamic> json)
  : id = json["cast_id"],
  character = json["character"],
  name = json["name"],
  img = json["profile_path"];
}