import 'package:flutter/material.dart';

import '../../core/auth/auth_api.dart';
import 'staff_models.dart';
import 'teacher_assessment_models.dart';

const _assessmentTypes = <String>['CLASSWORK', 'TEST', 'EXAM', 'PROJECT', 'OTHER'];

class TeacherAssessmentPage extends StatefulWidget {
  const TeacherAssessmentPage({super.key, required this.assignment});
  final TeachingAssignmentView assignment;
  @override
  State<TeacherAssessmentPage> createState() => _TeacherAssessmentPageState();
}

class _TeacherAssessmentPageState extends State<TeacherAssessmentPage> {
  final _api = AuthApi();
  final _titleController = TextEditingController();
  final _maxScoreController = TextEditingController(text: '100');
  final _weightController = TextEditingController();
  String _type = 'TEST';
  CreatedAssessmentView? _assessment;
  List<AssessmentRosterStudentView>? _roster;
  final Map<String, TextEditingController> _scoreControllers = {};
  final Map<String, TextEditingController> _remarkControllers = {};
  bool _busy = false;
  String? _message;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _maxScoreController.dispose();
    _weightController.dispose();
    for (final controller in _scoreControllers.values) controller.dispose();
    for (final controller in _remarkControllers.values) controller.dispose();
    super.dispose();
  }

  Future<void> _loadRoster() async {
    final assignment = widget.assignment;
    setState(() { _busy = true; _error = null; });
    try {
      final roster = await _api.assessmentRoster(
        classId: assignment.classId,
        termId: assignment.termId,
        subjectId: assignment.subjectId,
      );
      if (!mounted) return;
      for (final student in roster) {
        _scoreControllers.putIfAbsent(student.id, TextEditingController.new);
        _remarkControllers.putIfAbsent(student.id, TextEditingController.new);
      }
      setState(() { _roster = roster; });
    } catch (error) {
      if (mounted) setState(() { _error = 'Could not load the authoritative class roster: ' + _friendlyError(error); });
    } finally {
      if (mounted) setState(() { _busy = false; });
    }
  }

  Future<void> _createAssessment() async {
    if (!widget.assignment.canMarkAttendance) {
      _showError('Assessments cannot be changed for a closed term.');
      return;
    }
    final title = _titleController.text.trim();
    final maxScore = double.tryParse(_maxScoreController.text.trim());
    final weightText = _weightController.text.trim();
    final weight = weightText.isEmpty ? null : double.tryParse(weightText);
    if (title.length < 2) { _showError('Enter an assessment title.'); return; }
    if (maxScore == null || maxScore <= 0) { _showError('Maximum score must be greater than zero.'); return; }
    if (weightText.isNotEmpty && (weight == null || weight < 0 || weight > 100)) { _showError('Weight must be between 0 and 100.'); return; }

    setState(() { _busy = true; _error = null; _message = null; });
    try {
      final created = await _api.createAssessment(
        termId: widget.assignment.termId,
        subjectId: widget.assignment.subjectId,
        title: title,
        type: _type,
        maxScore: maxScore,
        weight: weight,
      );
      final roster = await _api.assessmentRoster(
        classId: widget.assignment.classId,
        termId: widget.assignment.termId,
        subjectId: widget.assignment.subjectId,
      );
      if (!mounted) return;
      for (final student in roster) {
        _scoreControllers.putIfAbsent(student.id, TextEditingController.new);
        _remarkControllers.putIfAbsent(student.id, TextEditingController.new);
      }
      setState(() {
        _assessment = created;
        _roster = roster;
        _message = 'Assessment created. Enter scores against the live class roster.';
      });
    } catch (error) {
      if (mounted) setState(() { _error = 'The assessment could not be created: ' + _friendlyError(error); });
    } finally {
      if (mounted) setState(() { _busy = false; });
    }
  }

  Future<void> _saveResults() async {
    final roster = _roster;
    final assessment = _assessment;
    if (roster == null || assessment == null) return;
    final maxScore = double.tryParse(assessment.maxScore);
    if (maxScore == null) { _showError('The server returned an invalid maximum score.'); return; }

    final results = <Map<String, dynamic>>[];
    for (final student in roster) {
      final text = _scoreControllers[student.id]?.text.trim() ?? '';
      if (text.isEmpty) continue;
      final score = double.tryParse(text);
      if (score == null || score < 0 || score > maxScore) {
        _showError('Score for ' + student.displayName + ' must be between 0 and ' + maxScore.toString() + '.');
        return;
      }
      final remark = _remarkControllers[student.id]?.text.trim() ?? '';
      results.add({
        'studentId': student.id,
        'score': score,
        if (remark.isNotEmpty) 'remark': remark,
      });
    }
    if (results.isEmpty) { _showError('Enter at least one score before saving.'); return; }

    setState(() { _busy = true; _error = null; _message = null; });
    try {
      final saved = await _api.enterAssessmentResults(assessmentId: assessment.id, results: results);
      if (!mounted) return;
      setState(() { _message = saved.length.toString() + ' result(s) saved successfully.'; });
    } catch (error) {
      if (mounted) setState(() { _error = 'Results could not be saved: ' + _friendlyError(error); });
    } finally {
      if (mounted) setState(() { _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    final roster = _roster;
    final assessment = _assessment;
    final entered = roster?.where((student) => (_scoreControllers[student.id]?.text.trim().isNotEmpty ?? false)).length ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Assessment entry')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(assignment.className, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(assignment.subject),
            const SizedBox(height: 4),
            Text(assignment.term + ' · ' + assignment.level + (assignment.programme == 'NONE' ? '' : ' · ' + assignment.programme), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Chip(avatar: Icon(assignment.canMarkAttendance ? Icons.lock_open_outlined : Icons.lock_outline, size: 16), label: Text(assignment.canMarkAttendance ? 'Term open' : 'Term closed')),
          ]))),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
            TextField(controller: _titleController, enabled: !_busy && assessment == null && assignment.canMarkAttendance, decoration: const InputDecoration(labelText: 'Assessment title', hintText: 'e.g. First class test')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(initialValue: _type, decoration: const InputDecoration(labelText: 'Type'), items: _assessmentTypes.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(growable: false), onChanged: _busy || assessment != null ? null : (value) { if (value != null) setState(() => _type = value); }),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: TextField(controller: _maxScoreController, enabled: !_busy && assessment == null && assignment.canMarkAttendance, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Maximum score'))), const SizedBox(width: 12), Expanded(child: TextField(controller: _weightController, enabled: !_busy && assessment == null && assignment.canMarkAttendance, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight', hintText: 'Optional')))]),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _busy || assessment != null || !assignment.canMarkAttendance ? null : _createAssessment, icon: const Icon(Icons.add_task_outlined), label: Text(_busy ? 'Working…' : 'Create assessment'))),
            if (assessment != null) ...[
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: Text(assessment.title + ' · max ' + assessment.maxScore, style: Theme.of(context).textTheme.titleMedium)),
            ],
          ]))),
          const SizedBox(height: 16),
          if (assessment == null && roster == null) Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const Text('The roster is loaded automatically when the assessment is created.'), const SizedBox(height: 8), OutlinedButton.icon(onPressed: _busy ? null : _loadRoster, icon: const Icon(Icons.people_outline), label: const Text('Preview roster'))]))),
          if (roster != null) ...[
            Row(children: [Expanded(child: Text('Results', style: Theme.of(context).textTheme.titleLarge)), Text(entered.toString() + '/' + roster.length.toString() + ' entered')]),
            const SizedBox(height: 8),
            ...roster.map((student) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(student.displayName), const SizedBox(height: 2), Text(student.admissionNumber ?? 'No admission number', style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 8), TextField(controller: _remarkControllers[student.id], enabled: !_busy && assessment != null, decoration: const InputDecoration(labelText: 'Remark (optional)'))])),
              const SizedBox(width: 12),
              SizedBox(width: 105, child: TextField(controller: _scoreControllers[student.id], enabled: !_busy && assessment != null, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Score'), onChanged: (_) => setState(() {}))),
            ])))),
            if (assessment != null) SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _busy ? null : _saveResults, icon: const Icon(Icons.save_outlined), label: Text(_busy ? 'Saving…' : 'Save results'))),
          ],
          if (_error != null) ...[const SizedBox(height: 12), Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))))],
          if (_message != null) ...[const SizedBox(height: 12), Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(_message!)))],
        ],
      ),
    );
  }

  void _showError(String message) => setState(() { _error = message; _message = null; });
  String _friendlyError(Object error) => error.toString().replaceFirst('Exception: ', '');
}