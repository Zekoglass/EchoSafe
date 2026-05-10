import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact_model.dart';

class ContactsProvider extends ChangeNotifier {
  List<TrustedContact> _contacts = [];

  List<TrustedContact> get contacts => _contacts;

  // Load contacts from storage when app starts
  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('trusted_contacts');
    if (data != null) {
      final List decoded = jsonDecode(data);
      _contacts = decoded.map((e) => TrustedContact.fromJson(e)).toList();
      notifyListeners();
    }
  }

  // Save contacts to storage
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(_contacts.map((c) => c.toJson()).toList());
    await prefs.setString('trusted_contacts', encoded);
  }

  // Add a new contact
  Future<void> addContact(String name, String phone) async {
    final contact = TrustedContact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      phone: phone.trim(),
    );
    _contacts.add(contact);
    notifyListeners();
    await _save();
  }

  // Delete a contact by id
  Future<void> deleteContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
    await _save();
  }
}