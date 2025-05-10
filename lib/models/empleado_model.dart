class Empleado {
  final int id;
  final String nombre;
  final String? cargo;
  final String? correo;
  final int? idDep;

  Empleado({
    required this.id,
    required this.nombre,
    this.cargo,
    this.correo,
    this.idDep,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['ID_Emp'],
      nombre: json['Nombre'],
      cargo: json['Cargo'],
      correo: json['Correo'],
      idDep: json['ID_Dep'],
    );
  }
}
