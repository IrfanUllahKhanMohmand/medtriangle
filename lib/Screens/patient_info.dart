import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/patient_info_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientInformationScreen extends StatefulWidget {
  const PatientInformationScreen({super.key});

  @override
  State<PatientInformationScreen> createState() =>
      _PatientInformationScreenState();
}

class _PatientInformationScreenState extends State<PatientInformationScreen> {
  Future<PatientInfoModel> fetchPatientInfo() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('patientinfo')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    if (snapshot.exists) {
      return PatientInfoModel.fromJson(snapshot.data()!);
    } else {
      throw Exception('Patient not found');
    }
  }

  Future<void> _launchUrl(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
  // void _makePhoneCall(String phoneNumber) async {
  //   final Uri _url = Uri.parse('tel:$phoneNumber');
  //   Future<void> _launchUrl() async {
  //     if (!await launchUrl(_url)) {
  //       throw Exception('Could not launch $_url');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PatientInfoModel>(
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
          final patientInfo = snapshot.data!;
          return SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'PATIENT INFO',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  patientInfo.imageUrl.isNotEmpty
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(patientInfo.imageUrl),
                        )
                      : const CircleAvatar(
                          radius: 60,
                        ),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Name', valuee: patientInfo.name),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Birthday', valuee: patientInfo.birthday),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Gender', valuee: patientInfo.gender),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'CNIC #', valuee: patientInfo.cnic),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Phone #', valuee: patientInfo.phone),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Address', valuee: patientInfo.address),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Email', valuee: patientInfo.email),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Blood Type', valuee: patientInfo.bloodType),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Consult Dr', valuee: patientInfo.consultDr),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Ward #', valuee: patientInfo.ward),
                  const SizedBox(height: 16),
                  InfoTile(keey: 'Bed #', valuee: patientInfo.bed),
                  const SizedBox(height: 16),
                  InfoTile(
                      keey: 'Appoint #', valuee: patientInfo.appointNumber),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .40,
                          child: const Text(
                            'Dr. Contact #',
                            softWrap: true,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .50,
                          child: Row(
                            children: [
                              Text(
                                patientInfo.doctorNumber,
                                softWrap: true,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                  onTap: () {
                                    _launchUrl(patientInfo.doctorNumber.trim());
                                  },
                                  child: const Icon(Icons.phone))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
            width: MediaQuery.of(context).size.width * .40,
            child: Text(
              '$keey:',
              softWrap: true,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .50,
            child: Text(
              valuee,
              softWrap: true,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
