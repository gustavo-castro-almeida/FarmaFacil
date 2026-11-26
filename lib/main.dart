
import 'package:flutter/material.dart';

void main() {
  runApp(const FarmaFacilApp());
}

// CORES DO FARMAFÁCIL
const azul = Color(0xFF245B9A);
const azulEscuro = Color(0xFF173B70);
const azulClaro = Color(0xFFDDEEFF);
const fundo = Color(0xFFF0F6FC);
const texto = Color(0xFF17345B);

class Medicamento {
  final String nome;
  final String apresentacao;
  final String horario;
  final String observacoes;

  Medicamento({
    required this.nome,
    required this.apresentacao,
    required this.horario,
    required this.observacoes,
  });
}

class FarmaFacilApp extends StatelessWidget {
  const FarmaFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FarmaFácil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: azul,
        ),
        scaffoldBackgroundColor: fundo,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
        ),
      ),
      home: const TelaInicial(),
    );
  }
}

// TELA INICIAL
class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final List<Medicamento> medicamentos = [];
  final TextEditingController pesquisaController =
      TextEditingController();

  final GlobalKey chaveLista = GlobalKey();

  bool pesquisaAberta = false;
  String pesquisa = '';

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  void mensagem(String valor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(valor)),
    );
  }

  Future<void> cadastrar() async {
    final novo = await Navigator.push<Medicamento>(
      context,
      MaterialPageRoute(
        builder: (_) => const TelaCadastro(),
      ),
    );

    if (!mounted) return;

    if (novo != null) {
      setState(() {
        medicamentos.add(novo);
      });

      mensagem('Medicamento cadastrado com sucesso!');
    }
  }

  Future<void> editar(Medicamento medicamento) async {
    final atualizado = await Navigator.push<Medicamento>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaCadastro(
          medicamentoExistente: medicamento,
        ),
      ),
    );

    if (!mounted) return;

    if (atualizado != null) {
      final indice = medicamentos.indexOf(medicamento);

      if (indice != -1) {
        setState(() {
          medicamentos[indice] = atualizado;
        });

        mensagem('Medicamento atualizado!');
      }
    }
  }

  Future<void> excluir(Medicamento medicamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir medicamento?'),
        content: Text(
          'Deseja remover ${medicamento.nome} da sua lista?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, excluir'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmar == true) {
      setState(() {
        medicamentos.remove(medicamento);
      });

      mensagem('Medicamento excluído.');
    }
  }

  void detalhes(Medicamento medicamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medicamento.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apresentação: ${medicamento.apresentacao}'),
            const SizedBox(height: 12),
            Text('Horário: ${medicamento.horario}'),
            const SizedBox(height: 12),
            Text(
              'Observações: '
              '${medicamento.observacoes.isEmpty ? "Nenhuma" : medicamento.observacoes}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void mostrarHorarios() {
    final ordenados = [...medicamentos]
      ..sort((a, b) => a.horario.compareTo(b.horario));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meus horários'),
        content: SizedBox(
          width: 420,
          child: ordenados.isEmpty
              ? const Text('Nenhum horário cadastrado.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: ordenados.length,
                  itemBuilder: (context, index) {
                    final item = ordenados[index];

                    return ListTile(
                      leading: const Icon(
                        Icons.access_time,
                        color: azul,
                      ),
                      title: Text(
                        item.horario,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(item.nome),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void irParaLista() {
    final contexto = chaveLista.currentContext;

    if (contexto != null) {
      Scrollable.ensureVisible(
        contexto,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void alternarPesquisa() {
    setState(() {
      pesquisaAberta = !pesquisaAberta;

      if (!pesquisaAberta) {
        pesquisa = '';
        pesquisaController.clear();
      }
    });
  }

  Widget cartaoAcao({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required Color cor,
    required VoidCallback aoClicar,
  }) {
    return Material(
      color: cor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: aoClicar,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icone,
                  color: azulEscuro,
                  size: 31,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: texto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: texto,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: azulEscuro,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cartaoMedicamento(Medicamento medicamento) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD6E5F5),
        ),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.medication,
                size: 35,
                color: azul,
              ),
              title: Text(
                medicamento.nome,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(medicamento.apresentacao),
              onTap: () => detalhes(medicamento),
            ),
          ),
          SizedBox(
            width: 180,
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: azul,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Horário: ${medicamento.horario}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              medicamento.observacoes.isEmpty
                  ? 'Sem observações'
                  : medicamento.observacoes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: () => editar(medicamento),
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          ),
          OutlinedButton.icon(
            onPressed: () => excluir(medicamento),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Excluir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB42335),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = medicamentos.where((item) {
      return item.nome
          .toLowerCase()
          .contains(pesquisa.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulEscuro,
        toolbarHeight: 80,
        title: const Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FarmaFácil',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Seu cuidado, mais simples',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: pesquisaAberta
                ? 'Fechar pesquisa'
                : 'Pesquisar medicamentos',
            onPressed: alternarPesquisa,
            icon: Icon(
              pesquisaAberta ? Icons.close : Icons.search,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 10),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              if (pesquisaAberta) ...[
                TextField(
                  controller: pesquisaController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 19),
                  decoration: const InputDecoration(
                    hintText: 'Digite o nome do medicamento',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (valor) {
                    setState(() {
                      pesquisa = valor;
                    });
                  },
                ),
                const SizedBox(height: 14),
              ],

              // CARTÃO DE BOAS-VINDAS
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD9EDFF),
                      Color(0xFFB8DEFA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final estreito = constraints.maxWidth < 650;

                    final boasVindas = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Olá! Que bom ter você aqui!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: texto,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Organize seus medicamentos e '
                          'consulte seus horários com '
                          'tranquilidade.',
                          style: TextStyle(
                            fontSize: 18,
                            color: texto,
                          ),
                        ),
                      ],
                    );

                    final imagem = Image.asset(
                      'assets/images/idosos.png',
                      height: 185,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) {
                        return const Icon(
                          Icons.elderly,
                          size: 100,
                          color: azul,
                        );
                      },
                    );

                    if (estreito) {
                      return Column(
                        children: [
                          boasVindas,
                          const SizedBox(height: 10),
                          imagem,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: boasVindas,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 2,
                          child: imagem,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ACESSOS RÁPIDOS
              LayoutBuilder(
                builder: (context, constraints) {
                  final estreito = constraints.maxWidth < 800;

                  final acoes = [
                    cartaoAcao(
                      icone: Icons.medication_outlined,
                      titulo: 'Meus medicamentos',
                      subtitulo: 'Ver e gerenciar',
                      cor: const Color(0xFFDCEEFF),
                      aoClicar: irParaLista,
                    ),
                    cartaoAcao(
                      icone: Icons.calendar_month,
                      titulo: 'Meus horários',
                      subtitulo: 'Consultar horários',
                      cor: const Color(0xFFFFEBD9),
                      aoClicar: mostrarHorarios,
                    ),
                    cartaoAcao(
                      icone: Icons.add_circle_outline,
                      titulo: 'Novo cadastro',
                      subtitulo: 'Adicionar medicamento',
                      cor: const Color(0xFFE3E9FF),
                      aoClicar: cadastrar,
                    ),
                  ];

                  if (estreito) {
                    return Column(
                      children: [
                        for (final acao in acoes) ...[
                          acao,
                          const SizedBox(height: 10),
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      for (int i = 0; i < acoes.length; i++) ...[
                        Expanded(child: acoes[i]),
                        if (i < acoes.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 60,
                child: FilledButton.icon(
                  onPressed: cadastrar,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 28,
                  ),
                  label: const Text(
                    'Cadastrar medicamento',
                    style: TextStyle(fontSize: 19),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: azul,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // LISTA DE MEDICAMENTOS
              Container(
                key: chaveLista,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFD6E5F5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      children: [
                        const Icon(
                          Icons.medication_liquid,
                          color: azul,
                          size: 32,
                        ),
                        const Text(
                          'Meus medicamentos',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: texto,
                          ),
                        ),
                        Chip(
                          label: Text(
                            '${medicamentos.length} cadastrados',
                          ),
                          backgroundColor: azulClaro,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (filtrados.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            medicamentos.isEmpty
                                ? 'Nenhum medicamento cadastrado.'
                                : 'Nenhum medicamento encontrado.',
                            style: const TextStyle(
                              fontSize: 18,
                              color: texto,
                            ),
                          ),
                        ),
                      ),
                    for (final item in filtrados)
                      cartaoMedicamento(item),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: azulClaro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'O FarmaFácil ajuda a organizar '
                  'informações e não substitui a '
                  'orientação de médicos ou farmacêuticos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: texto,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TELA DE CADASTRO E EDIÇÃO
class TelaCadastro extends StatefulWidget {
  final Medicamento? medicamentoExistente;

  const TelaCadastro({
    super.key,
    this.medicamentoExistente,
  });

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final formulario = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final observacoesController = TextEditingController();

  String apresentacao = 'Comprimido';
  TimeOfDay? horario;

  @override
  void initState() {
    super.initState();

    final medicamento = widget.medicamentoExistente;

    if (medicamento != null) {
      nomeController.text = medicamento.nome;
      observacoesController.text = medicamento.observacoes;
      apresentacao = medicamento.apresentacao;

      final partes = medicamento.horario.split(':');

      if (partes.length == 2) {
        horario = TimeOfDay(
          hour: int.parse(partes[0]),
          minute: int.parse(partes[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  Future<void> escolherHorario() async {
    final escolhido = await showTimePicker(
      context: context,
      initialTime: horario ?? TimeOfDay.now(),
    );

    if (escolhido != null) {
      setState(() {
        horario = escolhido;
      });
    }
  }

  void salvar() {
    if (!formulario.currentState!.validate()) return;

    if (horario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um horário.'),
        ),
      );
      return;
    }

    final horas = horario!.hour.toString().padLeft(2, '0');
    final minutos = horario!.minute.toString().padLeft(2, '0');

    Navigator.pop(
      context,
      Medicamento(
        nome: nomeController.text.trim(),
        apresentacao: apresentacao,
        horario: '$horas:$minutos',
        observacoes: observacoesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.medicamentoExistente != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulEscuro,
        foregroundColor: Colors.white,
        title: Text(
          editando
              ? 'Editar medicamento'
              : 'Cadastrar medicamento',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Form(
            key: formulario,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Informações do medicamento',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: texto,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Preencha conforme a orientação '
                  'recebida de um profissional.',
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: nomeController,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'Nome do medicamento',
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o nome do medicamento.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: apresentacao,
                  decoration: const InputDecoration(
                    labelText: 'Apresentação',
                  ),
                  items: [
                    'Comprimido',
                    'Cápsula',
                    'Xarope',
                    'Gotas',
                    'Pomada',
                    'Outro',
                  ].map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() {
                        apresentacao = valor;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: escolherHorario,
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    horario == null
                        ? 'Selecionar horário'
                        : 'Horário: ${horario!.format(context)}',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: observacoesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: salvar,
                    icon: const Icon(Icons.save),
                    label: Text(
                      editando
                          ? 'Salvar alterações'
                          : 'Salvar medicamento',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: azul,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
