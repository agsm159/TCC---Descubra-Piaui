class Validators {
  static String? validarTexto(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Este campo é obrigatório';
    }
    return null;
  }

  static String? validarCoordenada(String? valor) {
    final regex = RegExp(r'^-?\d+(\.\d+)?$');
    if (valor == null || !regex.hasMatch(valor)) {
      return 'Coordenada inválida';
    }
    return null;
  }
}
