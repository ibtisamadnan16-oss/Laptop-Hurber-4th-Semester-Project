import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_project/constants/firebase_collections.dart';
import 'package:e_project/screens/support/contact_support_screen.dart';
import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    final staticFaqs = [
      {
        "question": "How do I order a laptop on LaptopHarbor?",
        "answer":
            "Browse our catalog, select your desired laptop, add it to your cart, and proceed to checkout. You will receive an immediate confirmation and tracking number after placing the order.",
      },
      {
        "question": "What payment methods do you accept?",
        "answer":
            "We accept Cash on Delivery (COD), Debit/Credit Card, JazzCash, and EasyPaisa for secure, hassle-free transactions.",
      },
      {
        "question": "How can I maintain my laptop's battery and performance?",
        "answer":
            "Avoid extreme temperatures, do not leave it on soft surfaces that block vents, and keep your operating system and drivers up to date.",
      },
      {
        "question": "What is LaptopHarbor's warranty and return policy?",
        "answer":
            "All laptops come with an official 7-day checking warranty and manufacturer warranty coverage. Contact support for any warranty assistance.",
      },
      {
        "question": "Can I upgrade RAM or SSD after purchase?",
        "answer":
            "Yes! Most models from HP, Dell, and Lenovo allow easy memory and storage upgrades. Check the product specifications for exact upgrade slots.",
      },
      {
        "question": "How fast is delivery across Pakistan?",
        "answer":
            "Orders are dispatched within 24 hours. Standard delivery takes 2-4 business days.",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs"),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactSupportScreen(),
                ),
              );
            },
            icon: const Icon(Icons.headset_mic, color: Colors.white),
            label: const Text(
              "Support",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db.collection(Fc.faq).orderBy("order").snapshots(),
        builder: (context, s) {
          if (s.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final firestoreFaqs =
              s.hasData ? s.data!.docs.map((d) => d.data()).toList() : [];
          final allFaqs = [...staticFaqs, ...firestoreFaqs];

          if (allFaqs.isEmpty) {
            return const Center(
              child: Text(
                "❓ No FAQs available yet.\nPlease check back later.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: allFaqs.length,
            itemBuilder: (context, i) {
              final q = allFaqs[i];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shadowColor: Colors.red.withValues(alpha: 0.2),
                child: ExpansionTile(
                  leading: const Icon(Icons.help_outline, color: Colors.red),
                  title: Text(
                    q["question"],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        q["answer"],
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
