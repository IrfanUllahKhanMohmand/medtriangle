import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/treatment_model.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  Future<TreatmentModel> fetchPatientInfo() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('treatment')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    if (snapshot.exists) {
      return TreatmentModel.fromJson(snapshot.data()!);
    } else {
      throw Exception('Patient not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TreatmentModel>(
      future: fetchPatientInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the data to be fetched
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // If an error occurred during data retrieval
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          // Data retrieval successful
          final treatment = snapshot.data!;
          return SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'TREATMENT',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Medicines', valuee: treatment.medicines),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Injections', valuee: treatment.injections),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Surgery', valuee: treatment.surgery),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Drops', valuee: treatment.drops),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Food', valuee: treatment.food),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class InfoTile extends StatelessWidget {
  final String keey;
  final String valuee;
  const InfoTile({
    super.key,
    required this.keey,
    required this.valuee,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * .35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$keey:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  valuee,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
