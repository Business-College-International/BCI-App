import 'package:flutter/material.dart';

import '../../core/auth/auth_api.dart';
import 'staff_models.dart';
import 'teacher_assessment_models.dart';

class TeacherAssessmentCorrectionPage extends StatefulWidget {
  const TeacherAssessmentCorrectionPage({super.key, required this.assignment});

  final TeachingAssignmentView assignment;

  @override
  State<TeacherAssessmentCorrectionPage> createState() =>
      _TeacherAssessmentCorrectionPageState();
}

class _TeacherAssessmentCorrectionPageState
    extends State<TeacherAssessmentCorrectionPage> {
  final _api = AuthApi();

  List<AssignedAssessmentView> _assessments = const [];
  AssignedAssessmentView? _selected;
  List<AssessmentRosterStudentView> _roster = const [];

  final Map<String, TextEditingController> _scoreControllers = {};
  final Map<String, TextEditingController> _remarkControllers = {};
  final Map<String, String> _initialScores = {};
  final Map<String, String> _initialRemarks = {};

  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadAssessments();
  }

  @override
  void dispose() {
    for (final controller in _scoreControllers.values) {
      controller.dispose();
    }
    for (final controller in _remarkControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _ensureControllers(List<AssessmentRosterStudentView> roster) {
    for (final student in roster) {
      _scoreControllers.putIfAbsent(
        student.id,
        TextEditingController.new,
      );
      _remarkControllers.putIfAbsent(
        student.id,
        TextEditingController.new,
      );
    }
  }

  Future<void> _loadAssessments() async {
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });

    try {
      final assessments = await _api.assignedAssessments(
        classId: widget.assignment.classId,
        termId: widget.assignment.termId,
        subjectId: widget.assignment.subjectId,
      );

      if (!mounted) return;
      setState(() {
        _assessments = assessments;
        _message = assessments.isEmpty
            ? 'No existing assessments are available for this assignment.'
            : 'Select an assessment to inspect or correct existing results.';
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error =
              'Existing assessments could not be loaded: ' +
                  _friendlyError(error);
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectAssessment(AssignedAssessmentView selected) async {
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });

    try {
      final roster = await _api.assessmentRoster(
        classId: widget.assignment.classId,
        termId: widget.assignment.termId,
        subjectId: widget.assignment.subjectId,
      );

      if (!mounted) return;
      _ensureControllers(roster);

      for (final student in roster) {
        _scoreControllers[student.id]!.clear();
        _remarkControllers[student.id]!.clear();
        _initialScores.remove(student.id);
        _initialRemarks.remove(student.id);
      }

      for (final result in selected.results) {
        _scoreControllers[result.studentId]!.text = result.score;
        _remarkControllers[result.studentId]!.text = result.remark ?? '';
        _initialScores[result.studentId] = result.score;
        _initialRemarks[result.studentId] = result.remark ?? '';
      }

      setState(() {
        _selected = selected;
        _roster = roster;
        _message =
            'Request correction access for affected published students before saving their changed results.';
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error =
              'The selected assessment could not be loaded: ' +
                  _friendlyError(error);
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestCorrection(AssessmentRosterStudentView student) async {
    final controller = TextEditingController();

    try {
      final reason = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Request correction for ' + student.displayName),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Explain which assessment result needs correction.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.of(context).pop(value);
                }
              },
              child: const Text('Request'),
            ),
          ],
        ),
      );

      if (reason == null || reason.isEmpty) return;

      setState(() {
        _saving = true;
        _error = null;
        _message = null;
      });

      final correction = await _api.requestReportCardCorrection(
        studentId: student.id,
        termId: widget.assignment.termId,
        reason: reason,
      );

      if (!mounted) return;
      setState(() {
        _message =
            'Correction request ' +
                correction.id +
                ' is now ' +
                correction.decision +
                '.';
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error =
              'The correction request could not be created: ' +
                  _friendlyError(error);
        });
      }
    } finally {
      controller.dispose();
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveResults() async {
    final selected = _selected;
    if (selected == null || _roster.isEmpty) return;

    final maxScore = double.tryParse(selected.maxScore);
    if (maxScore == null) {
      _showError('The server returned an invalid maximum score.');
      return;
    }

    final results = <Map<String, dynamic>>[];
    for (final student in _roster) {
      final scoreText = _scoreControllers[student.id]!.text.trim();
      final remarkText = _remarkControllers[student.id]!.text.trim();

      if (scoreText.isEmpty) continue;

      final score = double.tryParse(scoreText);
      if (score == null || score < 0 || score > maxScore) {
        _showError(
          'Score for ' +
              student.displayName +
              ' must be between 0 and ' +
              maxScore.toString() +
              '.',
        );
        return;
      }

      final changed =
          scoreText != (_initialScores[student.id] ?? '') ||
          remarkText != (_initialRemarks[student.id] ?? '');

      if (!changed) continue;

      results.add({
        'studentId': student.id,
        'score': score,
        if (remarkText.isNotEmpty) 'remark': remarkText,
      });
    }

    if (results.isEmpty) {
      _showError('No changed scores or remarks are ready to save.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
      _message = null;
    });

    try {
      final saved = await _api.enterAssessmentResults(
        assessmentId: selected.id,
        results: results,
      );

      if (!mounted) return;

      for (final result in results) {
        final studentId = result['studentId'] as String;
        _initialScores[studentId] = result['score'].toString();
        _initialRemarks[studentId] =
            result['remark']?.toString() ?? '';
      }

      setState(() {
        _message = saved.length.toString() + ' changed result(s) saved.';
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error =
              'Results could not be saved: ' +
                  _friendlyError(error) +
                  '. Published students require a pending correction request.';
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    final canCreate = assignment.termStatus == 'OPEN';

    return Scaffold(
      appBar: AppBar(title: const Text('Assessment corrections')),
      body: RefreshIndicator(
        onRefresh: _loadAssessments,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.className,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(assignment.subject),
                    const SizedBox(height: 4),
                    Text(
                      assignment.term +
                          ' · ' +
                          assignment.level +
                          (assignment.programme == 'NONE'
                              ? ''
                              : ' · ' + assignment.programme),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      canCreate
                          ? 'Term is open. Existing published results still require a correction request.'
                          : 'Term is closed. Only approved correction workflows may change published results.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_loading && _assessments.isEmpty)
              const Center(child: CircularProgressIndicator()),
            if (!_loading && _assessments.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'No existing assessments were found for this class, subject and term.',
                  ),
                ),
              ),
            if (_assessments.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selected?.id,
                decoration:
                    const InputDecoration(labelText: 'Existing assessment'),
                items: _assessments
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(
                          item.title +
                              ' · ' +
                              item.type +
                              ' · max ' +
                              item.maxScore,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) return;
                        final selected =
                            _assessments.firstWhere((item) => item.id == value);
                        _selectAssessment(selected);
                      },
              ),
            if (_loading && _assessments.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(),
              ),
            if (_selected != null && _roster.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Results',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(_selected!.maxScore + ' max'),
                ],
              ),
              const SizedBox(height: 8),
              ..._roster.map(
                (student) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(student.displayName),
                              Text(
                                student.admissionNumber ??
                                    'No admission number',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _remarkControllers[student.id],
                                enabled: !_saving,
                                decoration: const InputDecoration(
                                  labelText: 'Remark',
                                ),
                              ),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                onPressed: _saving
                                    ? null
                                    : () => _requestCorrection(student),
                                icon: const Icon(Icons.rule_folder_outlined),
                                label: const Text('Request correction'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 105,
                          child: TextField(
                            controller: _scoreControllers[student.id],
                            enabled: !_saving,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration:
                                const InputDecoration(labelText: 'Score'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _saveResults,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Saving…' : 'Save changed results'),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(_message!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    setState(() {
      _error = message;
      _message = null;
    });
  }

  String _friendlyError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
