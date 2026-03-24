module.exports = (req, res, next) => {
  if (!req.usuario?.isAdmin) {
    return res.status(403).json({ erro: 'Acesso restrito a administradores' });
  }
  next();
};