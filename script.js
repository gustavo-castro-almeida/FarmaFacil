var meds = [
  {id:1,nome:"Losartana",forma:"Comprimido 50 mg",instr:"Tomar 1 comprimido com água, conforme receita.",obs:"Guardar longe da umidade.",horarios:[{h:"08:00",done:false},{h:"20:00",done:false}]},
  {id:2,nome:"Vitamina D",forma:"Gotas",instr:"Conforme orientação do médico.",obs:"",horarios:[{h:"12:00",done:false}]}
];
var nextId = 3, view = "lista", current = null, busca = "", draft = null, errs = {};
var app = document.getElementById("app");

function esc(s){return String(s==null?"":s).replace(/[&<>"]/g,function(c){return {"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c];});}
function find(id){return meds.filter(function(m){return m.id===id;})[0];}
function toast(msg){var t=document.getElementById("toast");t.textContent=msg;t.hidden=false;setTimeout(function(){t.hidden=true;},2200);}
function go(v,id){view=v;current=id||null;window.scrollTo(0,0);render();}

var AVISO = '<div class="aviso">O FarmaFácil organiza seus horários, mas não dá aconselhamento médico. Siga sempre a orientação do seu médico ou farmacêutico.</div>';

function render(){
  if(view==="lista") return renderLista();
  if(view==="detalhe") return renderDetalhe();
  renderForm();
}

/* TELA 1: lista e pesquisa (RF03, RF08) */
function renderLista(){
  var q = busca.trim().toLowerCase();
  var lista = meds.filter(function(m){return m.nome.toLowerCase().indexOf(q)>-1;});
  var h = '<h1>Meus medicamentos</h1><p class="sub">Toque em um medicamento para ver os detalhes.</p>';
  h += '<label for="q" style="margin-top:0">Pesquisar pelo nome</label><input id="q" type="search" placeholder="Digite o nome" value="'+esc(busca)+'">';
  h += '<div style="margin-top:16px">';
  if(!lista.length){
    h += '<div class="empty">'+(meds.length?'Nenhum medicamento encontrado com esse nome.':'Você ainda não cadastrou nenhum medicamento.')+'</div>';
  }
  lista.forEach(function(m){
    var pend = m.horarios.filter(function(x){return !x.done;}).length;
    var info = m.horarios.length ? (pend ? pend+' horário(s) pendente(s)' : 'Todos os horários concluídos') : 'Sem horários';
    h += '<button class="card" data-open="'+m.id+'"><b>'+esc(m.nome)+'</b><span>'+esc(m.forma||"Sem apresentação")+' — '+info+'</span></button>';
  });
  h += '</div><button class="primary block" id="novo">Adicionar medicamento</button>'+AVISO;
  app.innerHTML = h;
  var q2 = document.getElementById("q");
  q2.oninput = function(){busca=q2.value;var p=q2.selectionStart;renderLista();var n=document.getElementById("q");n.focus();n.setSelectionRange(p,p);};
  document.getElementById("novo").onclick = function(){draft={id:null,nome:"",forma:"",instr:"",obs:"",horarios:[]};errs={};go("form");};
  Array.prototype.forEach.call(app.querySelectorAll("[data-open]"),function(b){b.onclick=function(){go("detalhe",+b.getAttribute("data-open"));};});
}

/* TELA 2: detalhes e lembretes (RF04, RF07, RF06) */
function renderDetalhe(){
  var m = find(current);
  if(!m){go("lista");return;}
  var h = '<div class="top"><button class="ghost" id="voltar">Voltar</button></div><h1>'+esc(m.nome)+'</h1><p class="sub">'+esc(m.forma||"Sem apresentação informada")+'</p>';
  h += '<dl><dt>Instruções de uso</dt><dd>'+esc(m.instr||"Não informado")+'</dd><dt>Observações</dt><dd>'+esc(m.obs||"Nenhuma")+'</dd></dl>';
  h += '<h2>Horários de hoje</h2>';
  if(!m.horarios.length) h += '<div class="empty">Nenhum horário cadastrado. Toque em Editar para adicionar.</div>';
  m.horarios.slice().sort(function(a,b){return a.h<b.h?-1:1;}).forEach(function(x){
    h += '<div class="row'+(x.done?' ok':'')+'"><span class="t">'+x.h+'</span>'+
      (x.done?'<span class="ok-tag">Concluído</span>':'<button class="primary" data-done="'+x.h+'">Marcar como concluído</button>')+'</div>';
  });
  h += '<div class="actions"><button id="editar">Editar</button><button class="danger" id="excluir">Excluir</button></div>'+AVISO;
  app.innerHTML = h;
  document.getElementById("voltar").onclick=function(){go("lista");};
  document.getElementById("editar").onclick=function(){draft=JSON.parse(JSON.stringify(m));errs={};go("form",m.id);};
  document.getElementById("excluir").onclick=function(){
    document.getElementById("mp").textContent="“"+m.nome+"” será removido da sua lista. Essa ação não pode ser desfeita.";
    document.getElementById("modal").hidden=false;document.getElementById("mno").focus();
    document.getElementById("mno").onclick=function(){document.getElementById("modal").hidden=true;};
    document.getElementById("mok").onclick=function(){meds=meds.filter(function(x){return x.id!==m.id;});document.getElementById("modal").hidden=true;toast("Medicamento excluído");go("lista");};
  };
  Array.prototype.forEach.call(app.querySelectorAll("[data-done]"),function(b){b.onclick=function(){
    m.horarios.forEach(function(x){if(x.h===b.getAttribute("data-done"))x.done=true;});toast("Horário concluído");renderDetalhe();};});
}

/* TELA 3: cadastro e edição (RF01, RF02, RF05, RN01, RN05) */
function renderForm(){
  var editando = draft.id!==null;
  var h = '<div class="top"><button class="ghost" id="cancelar">Cancelar</button></div><h1>'+(editando?'Editar medicamento':'Novo medicamento')+'</h1>';
  h += '<label for="nome">Nome do medicamento <span class="hint">(obrigatório)</span></label><input id="nome" value="'+esc(draft.nome)+'" autocomplete="off">';
  if(errs.nome) h += '<p class="err">'+errs.nome+'</p>';
  h += '<label for="forma">Apresentação ou forma <span class="hint">(ex.: comprimido, gotas)</span></label><input id="forma" value="'+esc(draft.forma)+'">';
  h += '<label for="instr">Instruções de uso <span class="hint">(copie da bula ou da receita)</span></label><textarea id="instr">'+esc(draft.instr)+'</textarea>';
  h += '<label for="obs">Observações</label><textarea id="obs">'+esc(draft.obs)+'</textarea>';
  h += '<label for="hora">Horários de uso</label><div class="add-time"><input id="hora" type="time"><button id="addh">Adicionar</button></div>';
  if(errs.hora) h += '<p class="err">'+errs.hora+'</p>';
  draft.horarios.forEach(function(x,i){h += '<span class="chip">'+x.h+'<button data-rm="'+i+'" aria-label="Remover horário '+x.h+'">Remover</button></span>';});
  h += '<div class="actions"><button class="primary" id="salvar">Salvar medicamento</button></div>'+AVISO;
  app.innerHTML = h;
  function ler(){draft.nome=document.getElementById("nome").value;draft.forma=document.getElementById("forma").value;draft.instr=document.getElementById("instr").value;draft.obs=document.getElementById("obs").value;}
  document.getElementById("cancelar").onclick=function(){go(editando?"detalhe":"lista",editando?draft.id:null);};
  document.getElementById("addh").onclick=function(){
    ler();var v=document.getElementById("hora").value;errs={};
    if(!/^([01]\d|2[0-3]):[0-5]\d$/.test(v)){errs.hora="Informe um horário válido, por exemplo 08:30.";}
    else if(draft.horarios.some(function(x){return x.h===v;})){errs.hora="Esse horário já foi adicionado.";}
    else draft.horarios.push({h:v,done:false});
    renderForm();
  };
  Array.prototype.forEach.call(app.querySelectorAll("[data-rm]"),function(b){b.onclick=function(){ler();draft.horarios.splice(+b.getAttribute("data-rm"),1);renderForm();};});
  document.getElementById("salvar").onclick=function(){
    ler();errs={};
    if(!draft.nome.trim()){errs.nome="Digite o nome do medicamento para salvar.";renderForm();document.getElementById("nome").focus();return;}
    draft.nome=draft.nome.trim();
    if(editando){meds=meds.map(function(x){return x.id===draft.id?draft:x;});toast("Alterações salvas");go("detalhe",draft.id);}
    else{draft.id=nextId++;meds.push(draft);toast("Medicamento salvo");go("lista");}
  };
}
render();
