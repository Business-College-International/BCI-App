import 'package:flutter/material.dart';
import '../../core/auth/auth_api.dart';
import 'academic_report_models.dart';

class WardAcademicPage extends StatefulWidget {
  const WardAcademicPage({super.key, required this.ward});

  final dynamic ward;

  @override
  State<WardAcademicPage> createState() => _WardAcademicPageState();
}

class _WardAcademicPageState extends State<WardAcademicPage> {
  final _api = AuthApi();
  late Future<AcademicReportView> _report;

  @override
  void initState() {
    super.initState();
    _report = _api.currentAcademicReport(widget.ward.id as String);
  }

  void _retry() {
    setState(() => _report = _api.currentAcademicReport(widget.ward.id as String));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.ward.firstName} ${widget.ward.lastName} · Academic')),
      body: FutureBuilder<AcademicReportView>(
        future: _report,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Academic results could not be loaded.'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _retry, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }

          final report = snapshot.data!;
          final percentage = report.calculation.overallPercentage;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(report.term.name, style: Theme.of(context).textTheme.headlineSmall),
              Text(report.term.code, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overall performance'),
                      const SizedBox(height: 6),
                      Text(
                        percentage == null ? 'Pending policy' : '${percentage.toStringAsFixed(2)}%',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('Calculation: ${report.calculation.mode}'),
                      if (report.calculation.mode == 'MIXED_POLICY_REQUIRED')
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('The school has not defined how mixed weighted and unweighted assessments should combine.'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Subjects', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...report.subjects.map(
                (subject) => Card(
                  child: ListTile(
                    title: Text(subject.name),
                    subtitle: Text('${subject.assessmentCount} assessment(s)'),
                    trailing: Text('${subject.averagePercentage.toStringAsFixed(1)}%'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Assessments', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...report.assessments.map(
                (assessment) => Card(
                  child: ListTile(
                    title: Text(assessment.title),
                    subtitle: Text('${assessment.subjectName} · ${assessment.type}'),
                    trailing: Text('${assessment.score}/${assessment.maxScore}'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                report.grading.assigned ? 'Official grade assigned.' : report.grading.reason,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
