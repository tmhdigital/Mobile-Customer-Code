import 'dart:convert';

class TiarModel {
    bool? success;
    String? message;
    Pagination? pagination;
    List<TiarDataModel>? data;

    TiarModel({
        this.success,
        this.message,
        this.pagination,
        this.data,
    });

    factory TiarModel.fromRawJson(String str) => TiarModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory TiarModel.fromJson(Map<String, dynamic> json) => TiarModel(
        success: json["success"],
        message: json["message"],
        pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
        data: json["data"] == null ? [] : List<TiarDataModel>.from(json["data"]!.map((x) => TiarDataModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "pagination": pagination?.toJson(),
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class TiarDataModel {
    String? id;
    String? name;
    int? pointsThreshold;
    String? reward;
    int? accumulationRule;
    int? redemptionRule;
    int? minTotalSpend;
    bool? isActive;
    String? admin;
    DateTime? createdAt;
    DateTime? updatedAt;

    TiarDataModel({
        this.id,
        this.name,
        this.pointsThreshold,
        this.reward,
        this.accumulationRule,
        this.redemptionRule,
        this.minTotalSpend,
        this.isActive,
        this.admin,
        this.createdAt,
        this.updatedAt,
    });

    factory TiarDataModel.fromRawJson(String str) => TiarDataModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory TiarDataModel.fromJson(Map<String, dynamic> json) => TiarDataModel(
        id: json["_id"],
        name: json["name"],
        pointsThreshold: json["pointsThreshold"],
        reward: json["reward"],
        accumulationRule: json["accumulationRule"],
        redemptionRule: json["redemptionRule"],
        minTotalSpend: json["minTotalSpend"],
        isActive: json["isActive"],
        admin: json["admin"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "pointsThreshold": pointsThreshold,
        "reward": reward,
        "accumulationRule": accumulationRule,
        "redemptionRule": redemptionRule,
        "minTotalSpend": minTotalSpend,
        "isActive": isActive,
        "admin": admin,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
    };
}

class Pagination {
    int? total;
    int? limit;
    int? page;
    int? totalPage;

    Pagination({
        this.total,
        this.limit,
        this.page,
        this.totalPage,
    });

    factory Pagination.fromRawJson(String str) => Pagination.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        total: json["total"],
        limit: json["limit"],
        page: json["page"],
        totalPage: json["totalPage"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "limit": limit,
        "page": page,
        "totalPage": totalPage,
    };
}
