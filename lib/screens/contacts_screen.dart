import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/contacts_provider.dart';
import '../models/contact_model.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContactsProvider>();
    final contacts = provider.contacts;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        actions: [
          // Contact count badge
          if (contacts.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE94560).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${contacts.length}',
                  style: const TextStyle(
                      color: Color(0xFFE94560),
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactSheet(context),
        backgroundColor: const Color(0xFFE94560),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: contacts.isEmpty
          ? _buildEmptyState(context)
          : _buildContactList(context, contacts, provider),
    );
  }

  // ── Empty state ──────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline,
                color: Colors.white24, size: 56),
          ),
          const SizedBox(height: 20),
          const Text(
            'No trusted contacts yet',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add people who should be\nalerted in an emergency.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => _showAddContactSheet(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Add First Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contact list ─────────────────────────────────────────
  Widget _buildContactList(BuildContext context,
      List<TrustedContact> contacts, ContactsProvider provider) {
    return Column(
      children: [
        // Info banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE94560).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFFE94560).withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline,
                color: Color(0xFFE94560), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'These people will be alerted when you press the panic button.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    height: 1.4),
              ),
            ),
          ]),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final contact = contacts[i];
              return _ContactTile(
                contact: contact,
                onDelete: () => _confirmDelete(context, contact, provider),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Add contact bottom sheet ─────────────────────────────
  void _showAddContactSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Trusted Contact',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Name field
              _buildField(
                controller: nameCtrl,
                label: 'Full Name',
                hint: 'e.g. Mom, Alex...',
                icon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 14),

              // Phone field
              _buildField(
                controller: phoneCtrl,
                label: 'Phone Number',
                hint: 'e.g. +251 91 234 5678',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a phone number' : null,
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await context.read<ContactsProvider>().addContact(
                            nameCtrl.text,
                            phoneCtrl.text,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Save Contact'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Confirm delete dialog ────────────────────────────────
  void _confirmDelete(BuildContext context, TrustedContact contact,
      ContactsProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Contact',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove ${contact.name} from your trusted contacts?',
          style: const TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560)),
            onPressed: () {
              provider.deleteContact(contact.id);
              Navigator.pop(context);
            },
            child:
                const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Reusable text field ──────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF0F3460),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Color(0xFFE94560)),
      ),
    );
  }
}

// ── Contact Tile ───────────────────────────────────────────
class _ContactTile extends StatelessWidget {
  final TrustedContact contact;
  final VoidCallback onDelete;

  const _ContactTile({required this.contact, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE94560).withOpacity(0.15),
            child: Text(
              contact.name[0].toUpperCase(),
              style: const TextStyle(
                  color: Color(0xFFE94560),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                const SizedBox(height: 3),
                Text(contact.phone,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),

          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
            tooltip: 'Remove contact',
          ),
        ],
      ),
    );
  }
}