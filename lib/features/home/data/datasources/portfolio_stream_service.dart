import 'package:fintech_session_guard/features/home/data/models/portfolio_summary_model.dart';

abstract class PortfolioStreamService {
  Stream<PortfolioSummaryModel> getPortfolioStream();
}
