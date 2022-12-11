class SliderModel {
    String id;
    String url;
    String photo;
    String type;

    SliderModel({
        this.id,
        this.url,
        this.photo,
        this.type,
    });

    factory SliderModel.fromJson(Map<String, dynamic> json) => SliderModel(
        id: json["id"],
        url: json["url"],
        photo: json["photo"],
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "url": url,
        "photo": photo,
        "type": type,
    };
}