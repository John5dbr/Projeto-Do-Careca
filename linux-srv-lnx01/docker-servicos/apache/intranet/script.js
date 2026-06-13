/* ═══════════════════════════════════════
 DADOS — substitua por chamadas à API/backend
═══════════════════════════════════════ */

// Usuários (backend: consultar Active Directory / banco de usuários)
const USERS = {
  'admin': { senha:'admin123', nome:'Administrador TI', cargo:'Analista de TI', dept:'TI', unidade:'Matriz', email:'admin@3rmcorp.local', ramal:'101' },
  'joao.silva': { senha:'123456', nome:'João Silva', cargo:'Técnico de Redes', dept:'Infraestrutura', unidade:'Matriz', email:'joao.silva@3rmcorp.local', ramal:'102' },
  'ana.costa': { senha:'123456', nome:'Ana Costa', cargo:'Coordenadora RH', dept:'Recursos Humanos', unidade:'Filial', email:'ana.costa@3rmcorp.local', ramal:'201' },
};

// Avisos do mural (backend: tabela `avisos` no banco de dados)
const AVISOS = [
  { tipo:'urgente', titulo:'Manutenção programada da rede', data:'13/06/2026', autor:'TI', corpo:'A infraestrutura de rede passará por manutenção neste sábado das 22h às 02h. Sistemas podem ficar indisponíveis.' },
  { tipo:'info', titulo:'Novo ramal disponível na Filial', data:'10/06/2026', autor:'TI', corpo:'O ramal 2XX está disponível para colaboradores da unidade Filial. Entre em contato com o TI para configuração.' },
  { tipo:'aviso', titulo:'Preenchimento da folha de ponto', data:'08/06/2026', autor:'RH', corpo:'Lembrete: o prazo para preenchimento da folha de ponto de maio encerra nesta sexta-feira, 14/06.' },
  { tipo:'info', titulo:'Bem-vindos à nova intranet C.V!', data:'01/06/2026', autor:'Gestão', corpo:'A intranet foi lançada para centralizar comunicados, atividades e o calendário corporativo. Dúvidas? Fale com o TI.' },
];

// Atividades (backend: tabela `atividades` — atribuídas a usuário/equipe)
const ATIVIDADES = [
  { tipo:'tarefa', titulo:'Atualizar documentação de rede', desc:'Revisar e atualizar a tabela de endereçamento IP após mudanças da última semana.', status:'andamento', data:'20/06/2026', resp:'João Silva' },
  { tipo:'reuniao', titulo:'Reunião de alinhamento — TI e Gestão', desc:'Apresentação do status do projeto integrador para a coordenação.', status:'pendente', data:'17/06/2026', resp:'Admin TI' },
  { tipo:'entrega', titulo:'Relatório técnico final', desc:'Entrega do relatório completo com topologia, endereçamento e validações.', status:'pendente', data:'25/06/2026', resp:'Toda a equipe' },
  { tipo:'prazo', titulo:'Renovação de licenças de software', desc:'Prazo para renovar as licenças do sistema de monitoramento Zabbix.', status:'pendente', data:'30/06/2026', resp:'Admin TI' },
  { tipo:'tarefa', titulo:'Configurar backup automatizado — Filial', desc:'Script de backup semanal precisa ser implantado na unidade Filial.', status:'concluido', data:'10/06/2026', resp:'João Silva' },
  { tipo:'reuniao', titulo:'Treinamento GPO — novos colaboradores', desc:'Apresentação das políticas de segurança para os novos integrantes da equipe.', status:'concluido', data:'05/06/2026', resp:'Admin TI' },
];

// Eventos do calendário (backend: tabela `eventos`)
const EVENTOS = [
  { data: new Date(2026,5,17), titulo:'Reunião TI + Gestão', cor:'blue' },
  { data: new Date(2026,5,20), titulo:'Atualizar docs de rede', cor:'yellow' },
  { data: new Date(2026,5,25), titulo:'Entrega relatório final', cor:'red' },
  { data: new Date(2026,5,30), titulo:'Renovação licenças', cor:'red' },
  { data: new Date(2026,6,4), titulo:'Manutenção preventiva', cor:'yellow' },
  { data: new Date(2026,6,10), titulo:'Avaliação desempenho', cor:'green' },
];

// Notificações (backend: tabela `notificacoes`)
const NOTIFICACOES = [
  { texto: 'Novo aviso: Manutenção programada neste sábado.', tempo: 'Há 2h' },
  { texto: 'Atividade "Relatório técnico" vence em 12 dias.', tempo: 'Hoje' },
  { texto: 'Lembrete: preencher folha de ponto até sexta.', tempo: 'Ontem' },
];

/* ═══════════════════════════════════════
   ESTADO
═══════════════════════════════════════ */
let currentUser = null;
let calDate = new Date(2026, 5, 1); // junho 2026
const MONTHS = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];
const TODAY = new Date(2026, 5, 13);

/* ═══════════════════════════════════════
   LOGIN / LOGOUT
═══════════════════════════════════════ */
function doLogin() {
  const u = document.getElementById('inp-user').value.trim().toLowerCase();
  const p = document.getElementById('inp-pass').value;
  const user = USERS[u];
  if (user && user.senha === p) {
    currentUser = { login: u, ...user };
    document.getElementById('login-error').style.display = 'none';
    document.getElementById('login-page').style.display = 'none';
    document.getElementById('app').classList.add('visible');
    initApp();
  } else {
    document.getElementById('login-error').style.display = 'block';
  }
}

function doLogout() {
  currentUser = null;
  document.getElementById('app').classList.remove('visible');
  document.getElementById('login-page').style.display = 'flex';
  document.getElementById('inp-pass').value = '';
}

// Enter key no login
document.getElementById('inp-pass').addEventListener('keydown', e => { if(e.key==='Enter') doLogin(); });
document.getElementById('inp-user').addEventListener('keydown', e => { if(e.key==='Enter') document.getElementById('inp-pass').focus(); });

/* ═══════════════════════════════════════
   INIT
═══════════════════════════════════════ */
function initApp() {
  // topbar date
  const now = TODAY;
  const opts = { weekday:'long', day:'numeric', month:'long', year:'numeric' };
  document.getElementById('topbar-date').textContent = now.toLocaleDateString('pt-BR', opts);

  // mural hero
  const nome = currentUser.nome.split(' ')[0];
  const hora = now.getHours();
  const saud = hora < 12 ? 'Bom dia' : hora < 18 ? 'Boa tarde' : 'Boa noite';
  document.getElementById('mural-saudacao').textContent = `${saud}, ${nome}!`;
  document.getElementById('mural-subtitulo').textContent = `Confira os avisos e novidades — ${now.toLocaleDateString('pt-BR',{weekday:'long'})}.`;
  document.getElementById('mural-dia').textContent = now.getDate();
  document.getElementById('mural-mes').textContent = MONTHS[now.getMonth()].toUpperCase();

  // sidebar user
  const initials = currentUser.nome.split(' ').map(w=>w[0]).slice(0,2).join('');
  document.getElementById('sidebar-avatar').textContent = initials;
  document.getElementById('sidebar-name').textContent = nome;
  document.getElementById('sidebar-dept').textContent = currentUser.dept;

  // perfil
  document.getElementById('perfil-avatar').textContent = initials;
  document.getElementById('perfil-nome').textContent = currentUser.nome;
  document.getElementById('perfil-cargo').textContent = `${currentUser.cargo} — ${currentUser.unidade}`;
  document.getElementById('pf-nome').value = currentUser.nome;
  document.getElementById('pf-email').value = currentUser.email;
  document.getElementById('pf-dept').value = currentUser.dept;
  document.getElementById('pf-cargo').value = currentUser.cargo;
  document.getElementById('pf-ramal').value = currentUser.ramal;
  document.getElementById('pf-unidade').value = currentUser.unidade;

  // notificações
  renderNotif();

  // avisos
  renderAvisos();

  // atividades
  renderAtividades();

  // calendário
  renderCal();
  renderUpcoming();
}

/* ═══════════════════════════════════════
   NAVEGAÇÃO
═══════════════════════════════════════ */
const PAGE_TITLES = { mural:'Mural Geral', atividades:'Atividades', calendario:'Calendário', perfil:'Meu Perfil' };

document.querySelectorAll('.nav-item').forEach(item => {
  item.addEventListener('click', () => goPage(item.dataset.page));
});

function goPage(p) {
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  document.querySelector(`.nav-item[data-page="${p}"]`).classList.add('active');
  document.querySelectorAll('.page').forEach(pg => pg.classList.remove('active'));
  document.getElementById('page-' + p).classList.add('active');
  document.getElementById('topbar-title').textContent = PAGE_TITLES[p] || '';
  closeNotif();
}

/* ═══════════════════════════════════════
   MURAL — AVISOS
═══════════════════════════════════════ */
function renderAvisos() {
  const list = document.getElementById('avisos-list');
  list.innerHTML = AVISOS.map(a => `
    <div class="aviso-item ${a.tipo}">
      <div class="aviso-header">
        <div>
          <div class="aviso-titulo">${a.titulo}</div>
          <div class="aviso-meta">${a.data} &middot; ${a.autor}</div>
        </div>
        <span class="tag ${a.tipo==='urgente'?'tag-red':a.tipo==='aviso'?'tag-yellow':'tag-blue'}">
          ${a.tipo.charAt(0).toUpperCase()+a.tipo.slice(1)}
        </span>
      </div>
      <div class="aviso-corpo">${a.corpo}</div>
    </div>
  `).join('');
}

/* ═══════════════════════════════════════
   ATIVIDADES
═══════════════════════════════════════ */
const TIPO_ICON = {
  tarefa: `<svg viewBox="0 0 24 24"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>`,
  reuniao: `<svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>`,
  entrega: `<svg viewBox="0 0 24 24"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/></svg>`,
  prazo: `<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>`,
};
const STATUS_TAG = { pendente:'tag-yellow', andamento:'tag-blue', concluido:'tag-green' };
const STATUS_LABEL = { pendente:'Pendente', andamento:'Em andamento', concluido:'Concluído' };

function renderAtividades() {
  const filtroTipo = document.getElementById('filtro-tipo').value;
  const filtroStatus = document.getElementById('filtro-status').value;
  const lista = ATIVIDADES.filter(a =>
    (!filtroTipo || a.tipo === filtroTipo) &&
    (!filtroStatus || a.status === filtroStatus)
  );
  const el = document.getElementById('atividades-list');
  if (!lista.length) {
    el.innerHTML = `<div style="text-align:center;padding:48px;color:var(--gray-500);font-size:14px">Nenhuma atividade encontrada.</div>`;
    return;
  }
  el.innerHTML = lista.map(a => `
    <div class="atividade-card">
      <div class="atv-icon ${a.tipo}">${TIPO_ICON[a.tipo]}</div>
      <div class="atv-body">
        <div class="atv-titulo">${a.titulo}</div>
        <div class="atv-desc">${a.desc}</div>
        <div class="atv-footer">
          <span class="atv-date">
            <svg viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            ${a.data}
          </span>
          <span class="atv-resp">${a.resp}</span>
          <span class="tag ${STATUS_TAG[a.status]}">${STATUS_LABEL[a.status]}</span>
        </div>
      </div>
    </div>
  `).join('');
}

/* ═══════════════════════════════════════
   CALENDÁRIO
═══════════════════════════════════════ */
function renderCal() {
  const y = calDate.getFullYear(), m = calDate.getMonth();
  document.getElementById('cal-label').textContent = `${MONTHS[m]} ${y}`;
  const first = new Date(y, m, 1).getDay();
  const total = new Date(y, m+1, 0).getDate();
  const prevTotal = new Date(y, m, 0).getDate();
  let html = '';
  let cells = 0;
  for (let i = 0; i < first; i++) {
    const d = prevTotal - first + i + 1;
    html += `<div class="cal-day other-month"><div class="cal-day-num">${d}</div></div>`; cells++;
  }
  for (let d = 1; d <= total; d++) {
    const isToday = (y===TODAY.getFullYear() && m===TODAY.getMonth() && d===TODAY.getDate());
    const evs = EVENTOS.filter(e => e.data.getFullYear()===y && e.data.getMonth()===m && e.data.getDate()===d);
    const evsHtml = evs.map(e=>`<div class="cal-event ${e.cor}">${e.titulo}</div>`).join('');
    html += `<div class="cal-day${isToday?' today':''}" onclick="showToast('${d} de ${MONTHS[m]}')">
      <div class="cal-day-num">${d}</div>${evsHtml}
    </div>`; cells++;
  }
  const remain = 42 - cells;
  for (let d = 1; d <= remain; d++) {
    html += `<div class="cal-day other-month"><div class="cal-day-num">${d}</div></div>`;
  }
  document.getElementById('cal-days').innerHTML = html;
}

function calNav(dir) { calDate = new Date(calDate.getFullYear(), calDate.getMonth()+dir, 1); renderCal(); }
function calHoje() { calDate = new Date(TODAY.getFullYear(), TODAY.getMonth(), 1); renderCal(); }

function renderUpcoming() {
  const sorted = [...EVENTOS].sort((a,b)=>a.data-b.data).filter(e=>e.data>=TODAY).slice(0,5);
  const colors = { red:'#B91C1C', blue:'#1E40AF', green:'#065F46', yellow:'#92400E' };
  document.getElementById('upcoming-list').innerHTML = sorted.map(e=>`
    <div class="upcoming-item">
      <div class="upcoming-dot" style="background:${colors[e.cor]||'#888'}"></div>
      <div>
        <div class="upcoming-text">${e.titulo}</div>
        <div class="upcoming-sub">${e.data.toLocaleDateString('pt-BR',{day:'2-digit',month:'long'})}</div>
      </div>
    </div>
  `).join('');
}

/* ═══════════════════════════════════════
   NOTIFICAÇÕES
═══════════════════════════════════════ */
function renderNotif() {
  document.getElementById('notif-list').innerHTML = NOTIFICACOES.map(n=>`
    <div class="notif-item">
      <div class="notif-bullet"></div>
      <div>
        <div class="notif-text">${n.texto}</div>
        <div class="notif-time">${n.tempo}</div>
      </div>
    </div>
  `).join('');
  document.getElementById('notif-dot').style.display = NOTIFICACOES.length ? 'block' : 'none';
}

function toggleNotif() {
  document.getElementById('notif-panel').classList.toggle('open');
}
function closeNotif() { document.getElementById('notif-panel').classList.remove('open'); }
function clearNotif() {
  document.getElementById('notif-dot').style.display = 'none';
  document.getElementById('notif-list').innerHTML = `<div style="padding:20px;text-align:center;color:var(--gray-500);font-size:13px">Nenhuma notificação.</div>`;
}

// Clique fora fecha notif
document.addEventListener('click', e => {
  const panel = document.getElementById('notif-panel');
  const btn = document.querySelector('.topbar-icon-btn');
  if (!panel.contains(e.target) && !btn.contains(e.target)) closeNotif();
});

/* ═══════════════════════════════════════
   TOAST
═══════════════════════════════════════ */
let toastTimer;
function showToast(msg) {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => t.classList.remove('show'), 2800);
}