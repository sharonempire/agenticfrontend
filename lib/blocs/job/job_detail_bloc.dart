import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/job/job.dart';
import '../../repositories/interfaces/job_repository.dart';

abstract class JobDetailEvent extends Equatable {
  const JobDetailEvent();
  @override List<Object?> get props => [];
}
class JobDetailFetched extends JobDetailEvent {
  const JobDetailFetched(this.jobId);
  final String jobId;
  @override List<Object?> get props => [jobId];
}
class JobSaveToggled extends JobDetailEvent {
  const JobSaveToggled(this.jobId, this.isSaved);
  final String jobId;
  final bool isSaved;
  @override List<Object?> get props => [jobId, isSaved];
}

enum JobDetailStatus { initial, loading, loaded, error }

class JobDetailState extends Equatable {
  const JobDetailState({this.status = JobDetailStatus.initial, this.job, this.errorMessage});
  final JobDetailStatus status;
  final Job? job;
  final String? errorMessage;
  @override List<Object?> get props => [status, job, errorMessage];
}

class JobDetailBloc extends Bloc<JobDetailEvent, JobDetailState> {
  JobDetailBloc(this._repo) : super(const JobDetailState()) {
    on<JobDetailFetched>(_onFetched);
    on<JobSaveToggled>(_onSaveToggled);
  }
  final JobRepository _repo;

  Future<void> _onFetched(JobDetailFetched event, Emitter<JobDetailState> emit) async {
    emit(const JobDetailState(status: JobDetailStatus.loading));
    try {
      final job = await _repo.getJobById(event.jobId);
      emit(JobDetailState(status: JobDetailStatus.loaded, job: job));
    } catch (e) {
      emit(JobDetailState(status: JobDetailStatus.error, errorMessage: '$e'));
    }
  }

  Future<void> _onSaveToggled(JobSaveToggled event, Emitter<JobDetailState> emit) async {
    if (state.job == null) return;
    try {
      if (event.isSaved) { await _repo.unsaveJob(event.jobId); } else { await _repo.saveJob(event.jobId); }
      emit(JobDetailState(status: JobDetailStatus.loaded, job: state.job!.copyWith(isSaved: !event.isSaved)));
    } catch (e) {
      emit(JobDetailState(status: JobDetailStatus.loaded, job: state.job, errorMessage: 'Save failed: $e'));
    }
  }
}
