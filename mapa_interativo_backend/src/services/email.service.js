const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

module.exports = {
  async enviarEmailRecuperacao(email, token) {
    const link = `${process.env.BASE_URL}/api/auth/redefinir-senha?token=${token}`;

    await transporter.sendMail({
      from: `"Descubra Piauí" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Recuperação de senha — Descubra Piauí',
      html: `
        <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;padding:24px;">
          <h2 style="color:#1B5E20;">Descubra Piauí</h2>
          <h3>Recuperação de senha</h3>
          <p>Recebemos uma solicitação para redefinir a senha da sua conta.</p>
          <p>Clique no botão abaixo para criar uma nova senha:</p>
          <a href="${link}"
             style="display:inline-block;background:#1B5E20;color:white;padding:12px 28px;
                    text-decoration:none;border-radius:8px;margin:16px 0;font-size:16px;">
            Redefinir senha
          </a>
          <p style="color:#666;font-size:13px;">Este link expira em <strong>1 hora</strong>.</p>
          <p style="color:#666;font-size:13px;">
            Se você não solicitou a recuperação de senha, ignore este email.
          </p>
        </div>
      `,
    });
  },
};