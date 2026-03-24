const supabase = require('../config/supabase');

module.exports = {
  async uploadImagem(buffer, nomeArquivo, mimeType) {
    const { data, error } = await supabase.storage
      .from('imagens-pontos')
      .upload(nomeArquivo, buffer, {
        contentType: mimeType,
        upsert: true,
      });

    if (error) throw new Error(`Erro no upload: ${error.message}`);

    const { data: urlData } = supabase.storage
      .from('imagens-pontos')
      .getPublicUrl(nomeArquivo);

    return urlData.publicUrl;
  },

  async deletarImagem(url) {
    const nomeArquivo = url.split('/').pop();
    const { error } = await supabase.storage
      .from('imagens-pontos')
      .remove([nomeArquivo]);

    if (error) throw new Error(`Erro ao deletar: ${error.message}`);
  }
};