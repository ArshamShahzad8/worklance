import 'package:flutter/widgets.dart';

import '../../models/freelancer.dart';
import '../../models/job.dart';
import '../../models/project.dart';
import '../../models/proposal.dart';
import '../../models/service.dart';
import '../../models/user.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/repositories/project_repository.dart';

/// In-memory favorite state for service cards.
class FavoritesController extends ChangeNotifier {
  final Set<String> _ids = {};

  bool isFavorite(String serviceId) => _ids.contains(serviceId);
  int get count => _ids.length;

  void toggle(String serviceId) {
    if (!_ids.remove(serviceId)) _ids.add(serviceId);
    notifyListeners();
  }
}

/// Holds the current user profile.
class UserController extends ChangeNotifier {
  UserController(this._user);

  UserProfile _user;

  UserProfile get user => _user;

  static const String selfFreelancerId = 'me';
  static const String selfClientId = 'me_client';

  JobClient get asClient => JobClient(
    id: selfClientId,
    name: _user.name,
    avatarColor: _user.avatarColor,
    rating: _user.rating,
    reviewCount: _user.reviewCount,
    location: _user.location,
    jobsPosted: _user.jobsPosted,
    totalSpent: _user.totalSpent,
    paymentVerified: _user.paymentVerified,
    memberSince: _user.memberSince,
  );

  Freelancer get asFreelancer => Freelancer(
    id: selfFreelancerId,
    name: _user.name,
    title: _user.title,
    avatarColor: _user.avatarColor,
    rating: _user.rating,
    reviewCount: _user.reviewCount,
    bio: _user.bio,
    skills: _user.skills,
    location: _user.location,
    memberSince: _user.memberSince,
    completedJobs: _user.completedJobs,
  );

  void update({
    String? name,
    String? email,
    String? title,
    String? location,
  }) {
    _user = _user.copyWith(
      name: name,
      email: email,
      title: title,
      location: location,
    );
    notifyListeners();
  }

  void loginAs(String email) {
    final normalized = email.trim();
    final sameUser = _user.email.toLowerCase() == normalized.toLowerCase();
    _user = _user.copyWith(
      name: sameUser ? _user.name : _displayNameFromEmail(normalized),
      email: normalized,
    );
    notifyListeners();
  }

  void updateFreelancerProfile({required String bio, required List<String> skills}) {
    _user = _user.copyWith(bio: bio, skills: skills, isFreelancer: true);
    notifyListeners();
  }

  void recordJobPosted() {
    _user = _user.copyWith(jobsPosted: _user.jobsPosted + 1);
    notifyListeners();
  }

  /// Rolls a finished project into the user's profile stats (Week 5).
  void recordProjectCompleted({
    required ProjectRole role,
    required double amount,
  }) {
    _user = role == ProjectRole.freelancer
        ? _user.copyWith(completedJobs: _user.completedJobs + 1)
        : _user.copyWith(totalSpent: _user.totalSpent + amount);
    notifyListeners();
  }

  static String _displayNameFromEmail(String email) {
    final local = email.split('@').first;
    final parts = local.split(RegExp(r'[._\-+]'));
    final words = parts
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .toList();
    return words.isEmpty ? local : words.join(' ');
  }
}

/// Holds the services the current user offers as a freelancer.
class ServicesController extends ChangeNotifier {
  ServicesController([List<Service> initial = const []])
    : _services = List<Service>.from(initial);

  final List<Service> _services;

  List<Service> getAll() => List.unmodifiable(_services);

  Service? getById(String id) {
    for (final service in _services) {
      if (service.id == id) return service;
    }
    return null;
  }

  void add(Service service) {
    _services.insert(0, service);
    notifyListeners();
  }

  void update(Service service) {
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index == -1) return;
    _services[index] = service;
    notifyListeners();
  }

  void remove(String id) {
    _services.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}

/// Holds every job in the marketplace.
class JobsController extends ChangeNotifier {
  JobsController([List<Job>? initial])
    : _jobs = List<Job>.from(initial ?? JobRepository.getAll());

  final List<Job> _jobs;

  List<Job> getAll() => List.unmodifiable(_jobs);

  Job? getById(String id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  void add(Job job) {
    _jobs.insert(0, job);
    notifyListeners();
  }

  void incrementProposalsCount(String jobId) {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;
    _jobs[index] = _jobs[index].copyWith(
      proposalsCount: _jobs[index].proposalsCount + 1,
    );
    notifyListeners();
  }
}

/// Holds the proposals the current user has submitted.
class ProposalsController extends ChangeNotifier {
  final List<Proposal> _proposals = [];

  List<Proposal> getAll() {
    final sorted = List<Proposal>.from(_proposals)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return List.unmodifiable(sorted);
  }

  Proposal? getById(String id) {
    for (final proposal in _proposals) {
      if (proposal.id == id) return proposal;
    }
    return null;
  }

  bool hasAppliedToJob(String jobId) =>
      _proposals.any((p) => p.job.id == jobId);

  Proposal? getByJobId(String jobId) {
    for (final proposal in _proposals) {
      if (proposal.job.id == jobId) return proposal;
    }
    return null;
  }

  void add(Proposal proposal) {
    _proposals.insert(0, proposal);
    notifyListeners();
  }

  void updateStatus(String proposalId, ProposalStatus newStatus, {String? note}) {
    final index = _proposals.indexWhere((p) => p.id == proposalId);
    if (index == -1) return;
    _proposals[index] = _proposals[index].copyWithStatus(newStatus, note: note);
    notifyListeners();
  }

  void withdraw(String proposalId) {
    updateStatus(
      proposalId,
      ProposalStatus.withdrawn,
      note: 'Withdrawn by you.',
    );
  }
}

/// Holds every project and order the current user is involved in (Week 5).
class ProjectsController extends ChangeNotifier {
  ProjectsController([List<Project>? initial])
    : _projects = List<Project>.from(initial ?? ProjectRepository.getAll());

  final List<Project> _projects;

  List<Project> getAll() => List.unmodifiable(_projects);

  Project? getById(String id) {
    for (final project in _projects) {
      if (project.id == id) return project;
    }
    return null;
  }

  List<Project> open({ProjectRole? role}) => _projects
      .where((p) => p.status.isOpen && (role == null || p.role == role))
      .toList();

  int openCount({ProjectRole? role}) => open(role: role).length;

  Project? getByProposalId(String proposalId) {
    for (final project in _projects) {
      if (project.proposalId == proposalId) return project;
    }
    return null;
  }

  Project? openOrderForService(String serviceId) {
    for (final project in _projects) {
      if (project.serviceId == serviceId && project.status.isOpen) {
        return project;
      }
    }
    return null;
  }

  void add(Project project) {
    _projects.insert(0, project);
    notifyListeners();
  }

  void start(String projectId, {String? note}) {
    _updateStatus(
      projectId,
      ProjectStatus.active,
      note: note ?? 'Work started.',
      allowFrom: const {ProjectStatus.pending},
    );
  }

  void setMilestoneStatus(
    String projectId,
    String milestoneId,
    MilestoneStatus status,
  ) {
    final index = _indexOf(projectId);
    if (index == -1) return;
    final project = _projects[index];
    if (project.status.isFinal) return;

    final updated = [
      for (final milestone in project.milestones)
        if (milestone.id == milestoneId)
          milestone.copyWith(
            status: status,
            completedAt: status == MilestoneStatus.completed
                ? DateTime.now()
                : null,
            clearCompletedAt: status != MilestoneStatus.completed,
          )
        else
          milestone,
    ];

    var next = project.copyWith(milestones: updated);
    if (next.status == ProjectStatus.pending &&
        status != MilestoneStatus.pending) {
      next = next.copyWithStatus(
        ProjectStatus.active,
        note: 'First milestone started.',
      );
    }
    _projects[index] = next;
    notifyListeners();
  }

  ProjectDelivery? submitDelivery(
    String projectId, {
    required String message,
    List<String> attachments = const [],
  }) {
    final index = _indexOf(projectId);
    if (index == -1) return null;
    final project = _projects[index];
    if (project.status.isFinal) return null;

    final delivery = ProjectDelivery(
      id: 'delivery_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      submittedAt: DateTime.now(),
      attachments: List<String>.unmodifiable(attachments),
      revisionNumber: project.deliveries.length + 1,
    );

    _projects[index] = project
        .copyWith(deliveries: [...project.deliveries, delivery])
        .copyWithStatus(
          ProjectStatus.submitted,
          note: delivery.isRevision
              ? 'Revision ${delivery.revisionNumber - 1} submitted.'
              : 'Delivery submitted for review.',
        );
    notifyListeners();
    return delivery;
  }

  void requestRevision(String projectId, String note) {
    final index = _indexOf(projectId);
    if (index == -1) return;
    final project = _projects[index];
    if (project.status != ProjectStatus.submitted) return;

    final deliveries = [...project.deliveries];
    if (deliveries.isNotEmpty) {
      deliveries[deliveries.length - 1] = deliveries.last.copyWith(
        revisionNote: note,
      );
    }

    _projects[index] = project
        .copyWith(deliveries: deliveries)
        .copyWithStatus(ProjectStatus.active, note: 'Revision requested: $note');
    notifyListeners();
  }

  void complete(String projectId, {String? note}) {
    final index = _indexOf(projectId);
    if (index == -1) return;
    final project = _projects[index];
    if (project.status.isFinal) return;

    _projects[index] = project
        .copyWith(milestones: _completeAll(project.milestones))
        .copyWithStatus(
          ProjectStatus.completed,
          note: note ?? 'Delivery approved. Payment released.',
        );
    notifyListeners();
  }

  void cancel(String projectId, {String? reason}) {
    _updateStatus(
      projectId,
      ProjectStatus.cancelled,
      note: reason == null || reason.trim().isEmpty
          ? 'Cancelled.'
          : 'Cancelled: ${reason.trim()}',
      allowFrom: const {ProjectStatus.pending, ProjectStatus.active},
    );
  }

  int _indexOf(String projectId) =>
      _projects.indexWhere((p) => p.id == projectId);

  void _updateStatus(
    String projectId,
    ProjectStatus status, {
    String? note,
    Set<ProjectStatus> allowFrom = const {},
  }) {
    final index = _indexOf(projectId);
    if (index == -1) return;
    final project = _projects[index];
    if (allowFrom.isNotEmpty && !allowFrom.contains(project.status)) return;
    _projects[index] = project.copyWithStatus(status, note: note);
    notifyListeners();
  }

  static List<Milestone> _completeAll(List<Milestone> milestones) {
    final now = DateTime.now();
    return [
      for (final milestone in milestones)
        if (milestone.isCompleted)
          milestone
        else
          milestone.copyWith(
            status: MilestoneStatus.completed,
            completedAt: now,
          ),
    ];
  }
}

/// Combines the app's runtime state into one object.
class AppStore extends ChangeNotifier {
  AppStore({
    required this.favorites,
    required this.user,
    ServicesController? services,
    JobsController? jobs,
    ProposalsController? proposals,
    ProjectsController? projects,
  }) : services = services ?? ServicesController(),
       jobs = jobs ?? JobsController(),
       proposals = proposals ?? ProposalsController(),
       projects = projects ?? ProjectsController() {
    favorites.addListener(notifyListeners);
    user.addListener(notifyListeners);
    this.services.addListener(notifyListeners);
    this.jobs.addListener(notifyListeners);
    this.proposals.addListener(notifyListeners);
    this.projects.addListener(notifyListeners);
  }

  final FavoritesController favorites;
  final UserController user;
  final ServicesController services;
  final JobsController jobs;
  final ProposalsController proposals;
  final ProjectsController projects;

  /// Places an order for [service] and returns the resulting project (Week 5).
  Project placeServiceOrder(Service service) {
    final existing = projects.openOrderForService(service.id);
    if (existing != null) return existing;

    final profile = user.user;
    final project = Project.fromServiceOrder(
      service: service,
      clientName: profile.name,
      clientAvatarColor: profile.avatarColor,
    );
    projects.add(project);
    return project;
  }

  /// Marks a proposal accepted and opens the project (Week 5).
  Project? acceptProposal(String proposalId, {String? note}) {
    proposals.updateStatus(proposalId, ProposalStatus.accepted, note: note);
    final proposal = proposals.getById(proposalId);
    if (proposal == null) return null;

    final existing = projects.getByProposalId(proposalId);
    if (existing != null) return existing;

    final project = Project.fromAcceptedProposal(
      proposal: proposal,
      freelancer: user.asFreelancer,
    );
    projects.add(project);
    return project;
  }

  /// Completes a project and rolls the result into the user's profile stats.
  void completeProject(String projectId, {String? note}) {
    final project = projects.getById(projectId);
    if (project == null || project.status.isFinal) return;
    projects.complete(projectId, note: note);
    user.recordProjectCompleted(role: project.role, amount: project.amount);
  }
}

/// Exposes the [AppStore] to the widget tree.
class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in the widget tree');
    return scope!.notifier!;
  }
}
