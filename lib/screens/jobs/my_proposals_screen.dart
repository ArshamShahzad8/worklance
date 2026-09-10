import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/proposal_card.dart';

/// My Proposals screen: every proposal the current user has submitted as a
/// freelancer, newest first.
class MyProposalsScreen extends StatefulWidget {
  const MyProposalsScreen({super.key});

  @override
  State<MyProposalsScreen> createState() => _MyProposalsScreenState();
}

class _MyProposalsScreenState extends State<MyProposalsScreen> {
  /// Simulated initial load, matching Find Jobs' loading -> data pattern so
  /// swapping in a real API fetch later is a drop-in change.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Proposals')),
      body: SafeArea(
        child: _isLoading
            ? const LoadingIndicator(label: 'Loading your proposals...')
            : ListenableBuilder(
                listenable: store.proposals,
                builder: (context, _) {
                  final proposals = store.proposals.getAll();

                  if (proposals.isEmpty) {
                    return EmptyState(
                      icon: Icons.description_outlined,
                      title: 'No proposals yet',
                      message:
                          'Browse Find Jobs and submit a proposal to start '
                          'tracking your applications here.',
                      actionLabel: 'Find Jobs',
                      onAction: () =>
                          Navigator.of(context).pushNamed(AppRoutes.findJobs),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spaceMd,
                      AppConstants.spaceMd,
                      AppConstants.spaceMd,
                      AppConstants.spaceXl,
                    ),
                    itemCount: proposals.length,
                    itemBuilder: (context, index) {
                      final proposal = proposals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                        child: FadeSlideAnimation(
                          index: index,
                          child: ProposalCard(
                            proposal: proposal,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.proposalStatus,
                              arguments: proposal,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
