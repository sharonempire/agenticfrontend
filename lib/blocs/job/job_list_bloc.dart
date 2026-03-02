import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/job/job.dart';
import '../../repositories/interfaces/job_repository.dart';

abstract class JobListEvent extends Equatable {
  const JobListEvent();
  @override List<Object?> get props => [];
}
class JobListFetched extends JobListEvent {
  const JobListFetched({this.filter = const JobFilter()});
  final JobFilter filter;
  @override List<Object?> get props => [filter];
}
class JobListLoadMore extends JobListEvent {}

enum JobListStatus { initial, loading, loaded, loadingMore, error }

class JobListState extends Equatable {
  const JobListState({this.status = JobListStatus.initial, this.jobs = const [], this.filter = const JobFilter(), this.hasMore = true, this.errorMessage, this.total = 0});
  final JobListStatus status;
  final List<Job> jobs;
  final JobFilter filter;
  final bool hasMore;
  final String? errorMessage;
  final int total;

  JobListState copyWith({JobListStatus? status, List<Job>? jobs, JobFilter? filter, bool? hasMore, String? errorMessage, int? total}) =>
      JobListState(status: status ?? this.status, jobs: jobs ?? this.jobs, filter: filter ?? this.filter, hasMore: hasMore ?? this.hasMore, errorMessage: errorMessage, total: total ?? this.total);

  @override List<Object?> get props => [status, jobs, filter, hasMore, errorMessage, total];
}

class JobListBloc extends Bloc<JobListEvent, JobListState> {
  JobListBloc(this._repo) : super(const JobListState()) {
    on<JobListFetched>(_onFetched);
    on<JobListLoadMore>(_onLoadMore);
  }
  final JobRepository _repo;

  Future<void> _onFetched(JobListFetched event, Emitter<JobListState> emit) async {
    emit(state.copyWith(status: JobListStatus.loading, filter: event.filter));
    try {
      final result = await _repo.getJobs(event.filter);
      emit(state.copyWith(status: JobListStatus.loaded, jobs: result.items, hasMore: result.hasMore, total: result.total));
    } catch (e) {
      emit(state.copyWith(status: JobListStatus.error, errorMessage: '$e'));
    }
  }

  Future<void> _onLoadMore(JobListLoadMore event, Emitter<JobListState> emit) async {
    if (!state.hasMore || state.status == JobListStatus.loadingMore) return;
    emit(state.copyWith(status: JobListStatus.loadingMore));
    try {
      final nextFilter = JobFilter(query: state.filter.query, category: state.filter.category, type: state.filter.type, location: state.filter.location, isRemote: state.filter.isRemote, experienceLevel: state.filter.experienceLevel, page: state.filter.page + 1, pageSize: state.filter.pageSize);
      final result = await _repo.getJobs(nextFilter);
      emit(state.copyWith(status: JobListStatus.loaded, jobs: [...state.jobs, ...result.items], filter: nextFilter, hasMore: result.hasMore));
    } catch (e) {
      emit(state.copyWith(status: JobListStatus.loaded));
    }
  }
}
