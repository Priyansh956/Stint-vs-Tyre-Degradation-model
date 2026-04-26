import 'package:flutter/material.dart';
import '../models/stint_analysis.dart';
import '../services/analysis_service.dart';
import '../widgets/lap_time_chart.dart';
import '../widgets/residuals_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _yearController = TextEditingController(text: '2023');
  final _raceController = TextEditingController(text: 'Japanese Grand Prix');
  final _driverController = TextEditingController(text: 'VER');
  final _apiUrlController = TextEditingController(text: AnalysisService.baseUrl);

  bool _isLoading = false;
  String? _errorMessage;
  Map<int, StintAnalysis>? _results;

  Future<void> _analyze() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = null;
    });

    try {
      final year = int.parse(_yearController.text);
      final results = await AnalysisService.analyzeRace(
        year: year,
        race: _raceController.text,
        driver: _driverController.text,
      );
      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: TextField(
            controller: _apiUrlController,
            decoration: const InputDecoration(labelText: 'API Base URL'),
            onChanged: (val) {
              AnalysisService.baseUrl = val;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F1 Tyre Deg'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _yearController,
                          decoration: const InputDecoration(labelText: 'Year'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _raceController,
                          decoration: const InputDecoration(labelText: 'Race'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _driverController,
                          decoration: const InputDecoration(labelText: 'Driver'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _analyze,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Analyze'),
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            Expanded(
              child: _results == null
                  ? const Center(child: Text('Enter details and analyze'))
                  : ListView.builder(
                      itemCount: _results!.length,
                      itemBuilder: (context, index) {
                        final key = _results!.keys.elementAt(index);
                        final stint = _results![key]!;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ExpansionTile(
                            title: Text('Stint $key - ${stint.compound}'),
                            subtitle: Text(
                                'Laps: ${stint.numLaps} | Temp: ${stint.avgTrackTemp.toStringAsFixed(1)}°C'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text('RMSE: ${stint.rmse.toStringAsFixed(3)}'),
                                        Text('MAE: ${stint.mae.toStringAsFixed(3)}'),
                                        Text('R²: ${stint.r2.toStringAsFixed(3)}'),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Lap Times',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    LapTimeChart(stint: stint),
                                    const SizedBox(height: 24),
                                    const Text('Residuals',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    ResidualChart(stint: stint),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
