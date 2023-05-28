import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medtriangle/models/medical_info_model.dart';

class MedicalInformationScreen extends StatefulWidget {
  const MedicalInformationScreen({super.key});

  @override
  State<MedicalInformationScreen> createState() =>
      _MedicalInformationScreenState();
}

class _MedicalInformationScreenState extends State<MedicalInformationScreen> {
  Future<MedicalInfoModel> fetchPatientInfo() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('medicalinfo')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    if (snapshot.exists) {
      return MedicalInfoModel.fromJson(snapshot.data()!);
    } else {
      throw Exception('Patient not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MedicalInfoModel>(
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
          final medicalInfo = snapshot.data!;
          return SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'MEDICAL INFORMATION',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Name', valuee: medicalInfo.name),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Birthday', valuee: medicalInfo.birthday),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Gender', valuee: medicalInfo.gender),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Blood Type', valuee: medicalInfo.bloodType),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Diagnosis', valuee: medicalInfo.diagnosis),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'BP', valuee: medicalInfo.bp),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Sugar', valuee: medicalInfo.sugar),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Blood Test', valuee: medicalInfo.bloodTest),
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
