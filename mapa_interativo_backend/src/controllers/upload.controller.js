const uploadService = require('../services/upload.service');
const path = require('path');

module.exports = {
  async uploadImagem(req, res) {
    try {
      if (!req.file) {
        return res.status(400).json({ erro: 'Nenhum arquivo enviado' });
      }

      const extensao = path.extname(req.file.originalname);
      const nomeArquivo = `${Date.now()}-${Math.random()
        .toString(36)
        .substring(7)}${extensao}`;

      const url = await uploadService.uploadImagem(
        req.file.buffer,
        nomeArquivo,
        req.file.mimetype
      );

      return res.status(201).json({ url });
    } catch (error) {
      return res.status(500).json({ erro: error.message });
    }
  }
};