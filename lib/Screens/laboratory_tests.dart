// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:medtriangle/models/lab_test_model.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LabTestsScreen extends StatefulWidget {
  const LabTestsScreen({super.key});

  @override
  State<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends State<LabTestsScreen> {
  Future<List<LabTestModel>> fetchPatientInfo() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('labtests')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('reports')
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs
          .map((doc) => LabTestModel.fromJson(doc.data()))
          .toList();
    } else {
      throw Exception('Patient not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LabTestModel>>(
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
          final labTestInfo = snapshot.data!;
          return SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'REPORTS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: labTestInfo.length,
                        itemBuilder: ((context, index) {
                          return labTestInfo[index].name.trim().isEmpty
                              ? Container()
                              : LabTestTile(test: labTestInfo[index]);
                        })),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class LabTestTile extends StatefulWidget {
  final LabTestModel test;

  const LabTestTile({super.key, required this.test});

  @override
  State<LabTestTile> createState() => _LabTestTileState();
}

class _LabTestTileState extends State<LabTestTile> {
  Future<void> generatePDF(LabTestModel labTest) async {
    final doc = pw.Document();
    // final image = await imageFromAssetBundle('assets/splash.png');
    final netImage = await networkImage(labTest.imageUrl);

    doc.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Name: ${labTest.name}',
              style: const pw.TextStyle(fontSize: 20)),
          pw.Text('Date: ${labTest.date}',
              style: const pw.TextStyle(fontSize: 20)),
          pw.Text('Result: ${labTest.result}',
              style: const pw.TextStyle(fontSize: 20)),
          if (labTest.imageUrl.isNotEmpty)
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 10.0),
              alignment: pw.Alignment.center,
              child: pw.Image(netImage),
            ),
        ],
      ),
    ));

    final bytes = await doc.save();

    // Printing.sharePdf(bytes: bytes, filename: 'lab_test.pdf');
    final directory = await getExternalStorageDirectory();
    final folderPath = '${directory!.path}/medtriangle';
    await Directory(folderPath).create(recursive: true);
    final file = File(
        '$folderPath/${DateTime.now().millisecondsSinceEpoch}lab_test.pdf');
    await file.writeAsBytes(bytes);
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('PDF file saved successfully'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final filePath = file.path;
                await OpenFile.open(filePath);

                setState(() {});
              },
              child: const Text('Open'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.test.name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      trailing: TextButton(
        onPressed: () {
          generatePDF(widget.test);
        },
        child: const Text(
          'Download PDF',
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }
}
