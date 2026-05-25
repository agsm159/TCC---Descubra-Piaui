const authService = require("../services/auth.service");

module.exports = {
  async login(req, res) {
    try {
      const { email, senha } = req.body;
      const resultado = await authService.login(email, senha);
      return res.json(resultado);
    } catch (error) {
      return res.status(401).json({ erro: error.message });
    }
  },

  async registrar(req, res) {
    try {
      const usuario = await authService.registrar(req.body);
      return res.status(201).json(usuario);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async recuperarSenha(req, res) {
    try {
      const { email } = req.body;
      if (!email) return res.status(400).json({ erro: "Email é obrigatório" });
      const resultado = await authService.recuperarSenha(email);
      return res.json(resultado);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },

  async paginaRedefinirSenha(req, res) {
    const { token } = req.query;

    if (!token) {
      return res.status(400).send(`
      <html><body style="font-family:Arial;text-align:center;padding:40px;">
        <h2 style="color:#B71C1C;">Link inválido</h2>
        <p>Este link de recuperação é inválido ou já foi utilizado.</p>
      </body></html>
    `);
    }

    res.send(`
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Redefinir senha — Descubra Piauí</title>
      <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
          font-family: Arial, sans-serif;
          background: #f5f5f5;
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
          padding: 16px;
        }
        .card {
          background: white;
          border-radius: 12px;
          padding: 32px;
          width: 100%;
          max-width: 420px;
          box-shadow: 0 2px 12px rgba(0,0,0,0.1);
        }
        .logo {
          color: #1B5E20;
          font-size: 22px;
          font-weight: bold;
          margin-bottom: 4px;
        }
        h3 { color: #333; margin-bottom: 8px; }
        p { color: #666; font-size: 14px; margin-bottom: 24px; }
        label {
          display: block;
          font-size: 13px;
          color: #555;
          margin-bottom: 6px;
        }
        input {
          width: 100%;
          padding: 12px;
          border: 1px solid #ddd;
          border-radius: 8px;
          font-size: 14px;
          margin-bottom: 16px;
          transition: border-color 0.2s;
        }
        input:focus { outline: none; border-color: #1B5E20; }
        button {
          width: 100%;
          padding: 13px;
          background: #1B5E20;
          color: white;
          border: none;
          border-radius: 8px;
          font-size: 15px;
          cursor: pointer;
          transition: background 0.2s;
        }
        button:hover { background: #2E7D32; }
        button:disabled { background: #999; cursor: not-allowed; }
        .msg {
          padding: 12px;
          border-radius: 8px;
          margin-top: 16px;
          font-size: 14px;
          text-align: center;
          display: none;
        }
        .success { background: #E8F5E9; color: #1B5E20; display: block; }
        .error   { background: #FFEBEE; color: #B71C1C; display: block; }
      </style>
    </head>
    <body>
      <div class="card">
        <div class="logo">Descubra Piauí</div>
        <h3>Redefinir senha</h3>
        <p>Digite e confirme sua nova senha abaixo.</p>

        <form id="form">
          <label>Nova senha</label>
          <input type="password" id="senha" placeholder="Mínimo 6 caracteres" minlength="6" required/>

          <label>Confirmar senha</label>
          <input type="password" id="confirmar" placeholder="Repita a nova senha" required/>

          <button type="submit" id="btn">Redefinir senha</button>
        </form>

        <div id="msg" class="msg"></div>
      </div>

      <script>
        document.getElementById('form').addEventListener('submit', async (e) => {
          e.preventDefault();

          const senha    = document.getElementById('senha').value;
          const confirmar = document.getElementById('confirmar').value;
          const msg = document.getElementById('msg');
          const btn = document.getElementById('btn');

          msg.className = 'msg';
          msg.textContent = '';

          if (senha !== confirmar) {
            msg.className = 'msg error';
            msg.textContent = 'As senhas não coincidem.';
            return;
          }

          btn.disabled = true;
          btn.textContent = 'Aguarde...';

          try {
            const res = await fetch('/api/auth/redefinir-senha', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ token: '${token}', senha }),
            });

            const data = await res.json();

            if (res.ok) {
              msg.className = 'msg success';
              msg.textContent = 'Senha redefinida com sucesso! Você já pode entrar no app.';
              document.getElementById('form').style.display = 'none';
            } else {
              msg.className = 'msg error';
              msg.textContent = data.erro || 'Erro ao redefinir senha.';
              btn.disabled = false;
              btn.textContent = 'Redefinir senha';
            }
          } catch {
            msg.className = 'msg error';
            msg.textContent = 'Erro de conexão. Tente novamente.';
            btn.disabled = false;
            btn.textContent = 'Redefinir senha';
          }
        });
      </script>
    </body>
    </html>
  `);
  },

  async redefinirSenha(req, res) {
    try {
      const { token, senha } = req.body;
      if (!token || !senha) {
        return res.status(400).json({ erro: "Dados inválidos" });
      }
      const resultado = await authService.redefinirSenha(token, senha);
      return res.json(resultado);
    } catch (error) {
      return res.status(400).json({ erro: error.message });
    }
  },
};