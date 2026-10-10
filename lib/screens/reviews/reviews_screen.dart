import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_project/constants/firebase_collections.dart';
import 'package:e_project/services/firestore_service.dart';
import 'package:flutter/material.dart';

class ReviewsScreen extends StatefulWidget {
  final String productId;
  const ReviewsScreen({super.key, required this.productId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _rating = 5;
  final _comment = TextEditingController();
  String _sort = 'date';
  final _fs = FirestoreService();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Sort by:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sort,
                  items: const [
                    DropdownMenuItem(value: 'date', child: Text('Most recent')),
                    DropdownMenuItem(
                        value: 'helpful', child: Text('Most helpful')),
                  ],
                  onChanged: (v) => setState(() => _sort = v!),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(Fc.reviews)
                  .doc(widget.productId)
                  .collection('items')
                  .orderBy(_sort == 'helpful' ? 'helpful' : 'createdAt',
                      descending: true)
                  .snapshots(),
              builder: (context, s) {
                if (!s.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = s.data!.docs;
                if (items.isEmpty) {
                  return const Center(child: Text('No reviews yet.'));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = items[i].data();
                    final rating = (r['rating'] ?? 0) as int;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      title: Row(
                        children: List.generate(
                          5,
                          (idx) => Icon(
                            idx < rating ? Icons.star : Icons.star_border,
                            size: 18,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      subtitle: Text(r['comment'] ?? ''),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.thumb_up_alt_outlined, size: 18),
                          Text('${r['helpful'] ?? 0}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: List.generate(5, (i) {
                    final idx = i + 1;
                    return IconButton(
                      onPressed: () => setState(() => _rating = idx),
                      icon: Icon(
                        idx <= _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                    );
                  }),
                ),
                TextField(
                  controller: _comment,
                  decoration: const InputDecoration(
                    hintText: 'Write your review...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _comment.text.trim().isEmpty
                        ? null
                        : () async {
                            await _fs.createReview(
                              widget.productId,
                              _rating,
                              _comment.text.trim(),
                            );
                            _comment.clear();
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Review submitted')),
                            );
                            setState(() {});
                          },
                    child: const Text('Submit Review'),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
