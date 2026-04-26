class StintAnalysis {
  final String compound;
  final int numLaps;
  final double avgTrackTemp;

  final double rmse;
  final double mae;
  final double r2;

  final double beta0;
  final double beta1;
  final double beta2;
  final double beta3;

  final List<int> lapInStint;
  final List<double> lapTime;
  final List<double> trackTemp;
  final List<double> residuals;

  StintAnalysis({
    required this.compound,
    required this.numLaps,
    required this.avgTrackTemp,
    required this.rmse,
    required this.mae,
    required this.r2,
    required this.beta0,
    required this.beta1,
    required this.beta2,
    required this.beta3,
    required this.lapInStint,
    required this.lapTime,
    required this.trackTemp,
    required this.residuals,
  });

  factory StintAnalysis.fromJson(Map<String, dynamic> json) {
    return StintAnalysis(
      compound: json["compound"],
      numLaps: json["num_laps"],
      avgTrackTemp: json["avg_track_temp"].toDouble(),

      rmse: json["rmse"].toDouble(),
      mae: json["mae"].toDouble(),
      r2: json["r2"].toDouble(),

      beta0: json["beta_0"].toDouble(),
      beta1: json["beta_1"].toDouble(),
      beta2: json["beta_2"].toDouble(),
      beta3: json["beta_3"].toDouble(),

      lapInStint: List<int>.from(json["lap_in_stint"]),
      lapTime: List<double>.from(json["lap_time_s"]),
      trackTemp: List<double>.from(json["track_temp"]),
      residuals: List<double>.from(json["residuals"]),
    );
  }
}
