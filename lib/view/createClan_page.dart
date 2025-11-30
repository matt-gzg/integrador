import 'package:flutter/material.dart';
import 'package:integrador/model/appUser_model.dart';
import 'package:integrador/model/clan_model.dart';
import 'package:integrador/services/appUser_service.dart';
import 'package:integrador/services/clan_service.dart';
import 'package:integrador/view/home_page.dart';

class CreateClanPage extends StatefulWidget {
  final AppUser user;

  const CreateClanPage({required this.user, super.key});

  @override
  State<CreateClanPage> createState() => _CreateClanPageState();
}

class _CreateClanPageState extends State<CreateClanPage> {
  final _formKey = GlobalKey<FormState>();
  final _clanNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _clanNameController.dispose();
    super.dispose();
  }

  Future<void> _createClan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final clanName = _clanNameController.text.trim();

      // Criar o objeto Clan (id vazio pq o firestore gera)
      final clanModel = Clan(
        id: '',
        name: clanName,
        points: 0,
        leaderId: widget.user.id,
      );

      // 🔥 Cria o clã com líder automaticamente registrado como membro
      final clanId = await ClanService().createClan(
        clan: clanModel,
        leaderId: widget.user.id!,
        leaderName: widget.user.name,
      );

      // Atualiza o usuário com o novo clanId
      final updatedUser = widget.user.copyWith(clanId: clanId);
      await AppUserService().updateUser(updatedUser);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage(user: updatedUser)),
        (route) => false,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar clã: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Clan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _clanNameController,
                decoration: const InputDecoration(labelText: "Clan Name"),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please enter a clan name";
                  }
                  if (val.trim().length < 3) {
                    return "Name must be at least 3 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createClan,
                      child: const Text("Create Clan"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
