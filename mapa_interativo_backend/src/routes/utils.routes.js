const express = require('express');
const router = express.Router();

router.get('/resolver-link', async (req, res) => {
  const { url } = req.query;
  if (!url) return res.status(400).json({ erro: 'URL não fornecida' });

  try {
    const response = await fetch(url, {
      method: 'GET',
      redirect: 'follow',
    });
    return res.json({ urlFinal: response.url });
  } catch (e) {
    return res.status(400).json({ erro: 'Erro ao resolver o link' });
  }
});

module.exports = router;