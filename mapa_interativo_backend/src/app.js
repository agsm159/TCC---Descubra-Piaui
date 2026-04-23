const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth.routes');
const cidadesRoutes = require('./routes/cidades.routes');
const zonasRoutes = require('./routes/zonas.routes');
const pontosRoutes = require('./routes/pontos.routes');
const favoritosRoutes = require('./routes/favoritos.routes');
const uploadRoutes = require('./routes/upload.routes');
const horariosRoutes = require('./routes/horarios.routes');
const atividadesRoutes = require('./routes/atividades.routes');
const eventosRoutes = require('./routes/eventos.routes');
const avaliacoesRoutes = require('./routes/avaliacoes.routes');
const comentariosRoutes = require('./routes/comentarios.routes');
const utilsRoutes = require('./routes/utils.routes');

const app = express();

app.use(cors({
  origin: '*',
  methods: ['GET','POST','PUT','DELETE'],
  allowedHeaders: ['Content-Type','Authorization'],
}));
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/cidades', cidadesRoutes);
app.use('/api/zonas', zonasRoutes);
app.use('/api/pontos', pontosRoutes);
app.use('/api/favoritos', favoritosRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/pontos/:pontoId/horarios', horariosRoutes);
app.use('/api/pontos/:pontoId/atividades', atividadesRoutes);
app.use('/api/pontos/:pontoId/eventos', eventosRoutes);
app.use('/api/pontos/:pontoId/avaliacoes', avaliacoesRoutes);
app.use('/api/pontos/:pontoId/comentarios', comentariosRoutes);
app.use('/api/utils', utilsRoutes);

module.exports = app;