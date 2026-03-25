import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class Mensaje {
  final int numero;
  final String fecha;
  final String autor;
  final String mensaje;

  Mensaje(this.numero, this.fecha, this.autor, this.mensaje);

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      json['numero'],
      json['fecha'],
      json['autor'],
      json['mensaje'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mensajes',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Mensaje> mensajes = [];
  Mensaje? mensajeDelDia;

  @override
  void initState() {
    super.initState();
    cargarMensajes();
  }

  Future<void> cargarMensajes() async {
    final response =
        await rootBundle.loadString('assets/mensajes_normalizados.json');
    final data = json.decode(response);

    final lista = (data as List).map((e) => Mensaje.fromJson(e)).toList();
    final indice = DateTime.now().day % lista.length;

    setState(() {
      mensajes = lista;
      mensajeDelDia = lista[indice];
    });
  }

  void compartirMensaje(Mensaje m) {
    Share.share(
      "Mensaje #${m.numero}\n\n${m.mensaje}",
      subject: "Mensaje de la Virgen",
    );
  }

  void mostrarMensajeAleatorio() {
    if (mensajes.isEmpty) return;
    final random = Random();
    final m = mensajes[random.nextInt(mensajes.length)];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Mensaje #${m.numero}"),
        content: SingleChildScrollView(
          child: SelectableText(
            m.mensaje,
            style: const TextStyle(fontSize: 18, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => compartirMensaje(m),
            child: const Text("Compartir"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(title: const Text('Mensaje diario')),
      body: mensajeDelDia == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Mensaje #${mensajeDelDia!.numero}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      mensajeDelDia!.mensaje,
                      style: const TextStyle(fontSize: 22, height: 1.6),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MensajesPage()),
                        );
                      },
                      child: const Text("Ver todos los mensajes"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: mostrarMensajeAleatorio,
                      child: const Text("Mensaje aleatorio"),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

class MensajesPage extends StatefulWidget {
  const MensajesPage({super.key});

  @override
  State<MensajesPage> createState() => _MensajesPageState();
}

class _MensajesPageState extends State<MensajesPage> {
  Set<int> favoritos = {};
  List<Mensaje> mensajes = [];
  List<Mensaje> mensajesFiltrados = [];
  final TextEditingController buscador = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarMensajes();
    cargarFavoritos();
  }

  Future<void> cargarMensajes() async {
    final response =
        await rootBundle.loadString('assets/mensajes_normalizados.json');
    final data = json.decode(response);
    final lista = (data as List).map((e) => Mensaje.fromJson(e)).toList();

    setState(() {
      mensajes = lista;
      mensajesFiltrados = lista;
    });
  }

  Future<void> cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favoritos') ?? [];
    favoritos = favs.map(int.parse).toSet();
    setState(() {});
  }

  Future<void> toggleFavorito(int numero) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (favoritos.contains(numero)) {
        favoritos.remove(numero);
      } else {
        favoritos.add(numero);
      }
    });

    prefs.setStringList(
      'favoritos',
      favoritos.map((e) => e.toString()).toList(),
    );
  }

  void compartirMensaje(Mensaje m) {
    Share.share(
      "Mensaje #${m.numero}\n\n${m.mensaje}",
      subject: "Mensaje de la Virgen",
    );
  }

  void filtrarMensajes(String texto) {
    final resultados = mensajes.where((m) =>
        m.mensaje.toLowerCase().contains(texto.toLowerCase()));
    setState(() {
      mensajesFiltrados = resultados.toList();
    });
  }

  void mostrarMensajeAleatorio() {
    if (mensajes.isEmpty) return;
    final random = Random();
    final m = mensajes[random.nextInt(mensajes.length)];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Mensaje #${m.numero}"),
        content: SingleChildScrollView(
          child: SelectableText(
            m.mensaje,
            style: const TextStyle(fontSize: 18, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => compartirMensaje(m),
            child: const Text("Compartir"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Todos los mensajes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            tooltip: "Favoritos",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritosPage(
                    favoritos: favoritos,
                    mensajes: mensajes,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: mostrarMensajeAleatorio,
          ),
        ],
      ),
      body: mensajes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: buscador,
                    decoration: const InputDecoration(
                      labelText: "Buscar mensaje...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filtrarMensajes,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: mensajesFiltrados.length,
                    itemBuilder: (context, index) {
                      final m = mensajesFiltrados[index];
                      return ListTile(
                        title: Text("Mensaje #${m.numero}"),
                        subtitle: Text(
                          m.mensaje,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                favoritos.contains(m.numero)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: favoritos.contains(m.numero)
                                    ? Colors.amber
                                    : null,
                              ),
                              onPressed: () => toggleFavorito(m.numero),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () => compartirMensaje(m),
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Mensaje #${m.numero}"),
                              content: SingleChildScrollView(
                                child: SelectableText(
                                  m.mensaje,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class FavoritosPage extends StatelessWidget {
  final Set<int> favoritos;
  final List<Mensaje> mensajes;

  const FavoritosPage({
    super.key,
    required this.favoritos,
    required this.mensajes,
  });

  @override
  Widget build(BuildContext context) {
    final listaFavoritos =
        mensajes.where((m) => favoritos.contains(m.numero)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(title: const Text("Mensajes favoritos")),
      body: listaFavoritos.isEmpty
          ? const Center(
              child: Text(
                "No tenés mensajes favoritos todavía",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: listaFavoritos.length,
              itemBuilder: (context, index) {
                final m = listaFavoritos[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mensaje #${m.numero}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          m.mensaje,
                          style: const TextStyle(fontSize: 18, height: 1.5),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
