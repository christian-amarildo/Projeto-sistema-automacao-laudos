import 'package:uuid/uuid.dart';

class CaseModel {
  final CaseHeader cabecalho;
  final List<EvidenceModel> evidencias;

  CaseModel({required this.cabecalho, required this.evidencias});

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      cabecalho: CaseHeader.fromJson(json['cabecalho']),
      evidencias: (json['evidencias'] as List)
          .map((e) => EvidenceModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cabecalho': cabecalho.toJson(),
      'evidencias': evidencias.map((e) => e.toJson()).toList(),
    };
  }
}

class CaseHeader {
  final String bop;
  final String protocolo;
  final String peritoId;
  final String dataCriacao;
  final String modeloCrime;

  CaseHeader({
    required this.bop,
    required this.protocolo,
    required this.peritoId,
    required this.dataCriacao,
    required this.modeloCrime,
  });

  factory CaseHeader.fromJson(Map<String, dynamic> json) {
    return CaseHeader(
      bop: json['bop'] ?? '',
      protocolo: json['protocolo'] ?? '',
      peritoId: json['perito_id'] ?? '',
      dataCriacao: json['data_criacao'] ?? '',
      modeloCrime: json['modelo_crime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bop': bop,
      'protocolo': protocolo,
      'perito_id': peritoId,
      'data_criacao': dataCriacao,
      'modelo_crime': modeloCrime,
    };
  }
}

class EvidenceModel {
  final String id;
  final String tipo;
  final String caminhoLocal;
  final String hashSha256;
  final String timestamp;
  final bool validado;

  EvidenceModel({
    String? id,
    required this.tipo,
    required this.caminhoLocal,
    required this.hashSha256,
    required this.timestamp,
    this.validado = false,
  }) : id = id ?? const Uuid().v4();

  factory EvidenceModel.fromJson(Map<String, dynamic> json) {
    return EvidenceModel(
      id: json['id'],
      tipo: json['tipo'] ?? '',
      caminhoLocal: json['caminho_local'] ?? '',
      hashSha256: json['hash_sha256'] ?? '',
      timestamp: json['timestamp'] ?? '',
      validado: json['validado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'caminho_local': caminhoLocal,
      'hash_sha256': hashSha256,
      'timestamp': timestamp,
      'validado': validado,
    };
  }
}
