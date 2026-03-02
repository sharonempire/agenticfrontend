import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/course/course.dart';
import '../../repositories/interfaces/course_repository.dart';

// Events
abstract class CourseListEvent extends Equatable {
  const CourseListEvent();
  @override List<Object?> get props => [];
}
class CourseListFetched extends CourseListEvent {
  const CourseListFetched({this.filter = const CourseFilter()});
  final CourseFilter filter;
  @override List<Object?> get props => [filter];
}
class CourseListLoadMore extends CourseListEvent {}
class CourseListRefreshed extends CourseListEvent {}

// State
enum CourseListStatus { initial, loading, loaded, loadingMore, error }

class CourseListState extends Equatable {
  const CourseListState({this.status = CourseListStatus.initial, this.courses = const [], this.filter = const CourseFilter(), this.hasMore = true, this.errorMessage, this.total = 0});
  final CourseListStatus status;
  final List<Course> courses;
  final CourseFilter filter;
  final bool hasMore;
  final String? errorMessage;
  final int total;

  CourseListState copyWith({CourseListStatus? status, List<Course>? courses, CourseFilter? filter, bool? hasMore, String? errorMessage, int? total}) =>
      CourseListState(status: status ?? this.status, courses: courses ?? this.courses, filter: filter ?? this.filter, hasMore: hasMore ?? this.hasMore, errorMessage: errorMessage, total: total ?? this.total);

  @override List<Object?> get props => [status, courses, filter, hasMore, errorMessage, total];
}

// BLoC
class CourseListBloc extends Bloc<CourseListEvent, CourseListState> {
  CourseListBloc(this._repo) : super(const CourseListState()) {
    on<CourseListFetched>(_onFetched);
    on<CourseListLoadMore>(_onLoadMore);
    on<CourseListRefreshed>(_onRefreshed);
  }
  final CourseRepository _repo;

  Future<void> _onFetched(CourseListFetched event, Emitter<CourseListState> emit) async {
    emit(state.copyWith(status: CourseListStatus.loading, filter: event.filter));
    try {
      final result = await _repo.getCourses(event.filter);
      emit(state.copyWith(status: CourseListStatus.loaded, courses: result.items, hasMore: result.hasMore, total: result.total));
    } catch (e) {
      emit(state.copyWith(status: CourseListStatus.error, errorMessage: '$e'));
    }
  }

  Future<void> _onLoadMore(CourseListLoadMore event, Emitter<CourseListState> emit) async {
    if (!state.hasMore || state.status == CourseListStatus.loadingMore) return;
    emit(state.copyWith(status: CourseListStatus.loadingMore));
    try {
      final nextFilter = CourseFilter(query: state.filter.query, category: state.filter.category, level: state.filter.level, isFree: state.filter.isFree, provider: state.filter.provider, page: state.filter.page + 1, pageSize: state.filter.pageSize);
      final result = await _repo.getCourses(nextFilter);
      emit(state.copyWith(status: CourseListStatus.loaded, courses: [...state.courses, ...result.items], filter: nextFilter, hasMore: result.hasMore));
    } catch (e) {
      emit(state.copyWith(status: CourseListStatus.loaded));
    }
  }

  Future<void> _onRefreshed(CourseListRefreshed event, Emitter<CourseListState> emit) async {
    final refreshFilter = CourseFilter(query: state.filter.query, category: state.filter.category, level: state.filter.level, isFree: state.filter.isFree, provider: state.filter.provider, page: 1, pageSize: state.filter.pageSize);
    add(CourseListFetched(filter: refreshFilter));
  }
}
